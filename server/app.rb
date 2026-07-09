# Complete your server/app.rb file
require 'sinatra/base'
require 'stripe'
require 'json'
require 'dotenv/load'
require 'rack/cors'

# Explicitly load .env from parent directory
Dotenv.load(File.join(File.dirname(__FILE__), '..', '.env'))

def parsed_allowed_origins
  env_origins = ENV['ALLOWED_ORIGINS'].to_s.split(',').map(&:strip).reject(&:empty?)
  default_origins = [
    'https://donate.mosqueofislamicbrotherhood.org',
    'https://mosqueofislamicbrotherhood.org',
    'https://www.mosqueofislamicbrotherhood.org',
    'http://localhost:3000',
    'http://127.0.0.1:3000'
  ]

  (env_origins.empty? ? default_origins : env_origins).uniq
end

# Verify environment variables are loaded
puts "🔍 Environment check:"
puts "   STRIPE_SECRET_KEY: #{ENV['STRIPE_SECRET_KEY'] ? 'SET' : 'MISSING'}"
puts "   STRIPE_PUBLISHABLE_KEY: #{ENV['STRIPE_PUBLISHABLE_KEY'] ? 'SET' : 'MISSING'}"
puts "   PORT: #{ENV['PORT'] || 'DEFAULT'}"

# Load services
require_relative 'services/donation_service'
require_relative 'services/reader_payment_service'
require_relative 'services/terminal_service'

class DonationApp < Sinatra::Base
  
  # CORS middleware
  use Rack::Cors do
    allow do
      origins(*parsed_allowed_origins)
      resource '*', 
        headers: :any, 
        methods: [:get, :post, :put, :delete, :options]
    end
  end

  # Configuration
  configure do
    # Verify and set Stripe API key
    stripe_key = ENV['STRIPE_SECRET_KEY']
    if stripe_key.nil? || stripe_key.empty?
      puts "❌ ERROR: STRIPE_SECRET_KEY not found in environment!"
      puts "   Check your Render environment variables or .env file"
      exit 1
    end
    
    Stripe.api_key = stripe_key
    puts "✅ Stripe API key configured successfully"
    
    set :port, ENV['PORT'] || 4242
    set :bind, '0.0.0.0'
    set :public_folder, File.expand_path('../client/public', __dir__)
    enable :static
  end

  # Health check with environment info
  get '/health' do
    content_type :json
    { 
      status: 'ok', 
      timestamp: Time.now,
      app: 'donation-app',
      version: '1.0.0',
      ruby_version: RUBY_VERSION,
      environment: ENV['RACK_ENV'] || 'development',
      stripe_configured: !ENV['STRIPE_SECRET_KEY'].nil?
    }.to_json
  end

  # Connection token for Terminal
  post '/api/connection_token' do
    content_type :json
    
    begin
      puts "🎫 API: Creating connection token for donation app..."
      puts "   Using Stripe key: #{ENV['STRIPE_SECRET_KEY'][0..10]}..."
      
      connection_token = Stripe::Terminal::ConnectionToken.create
      
      puts "✅ API: Connection token created successfully"
      
      { secret: connection_token.secret }.to_json
      
    rescue Stripe::StripeError => e
      puts "❌ API: Connection token error: #{e.message}"
      status 400
      { error: e.message }.to_json
    end
  end

  # Create donation payment
  post '/api/donations' do
    content_type :json
    
    begin
      data = JSON.parse(request.body.read)
      amount = data['amount']
      donor_name = data['donor_name'] || 'Anonymous'
      message = data['message'] || ''
      event_name = data['event_name'] || 'Fundraising Event'
      
      raise "Missing amount" unless amount
      raise "Amount must be at least 50 cents" if amount < 50
      
      puts "💰 API: Creating donation payment: $#{amount/100.0} from #{donor_name}"
      
      result = DonationService.create_donation_payment(amount, donor_name, message, event_name)
      
      result.to_json
      
    rescue StandardError => e
      puts "❌ API: Create donation error: #{e.message}"
      status 400
      { success: false, error: e.message }.to_json
    end
  end

  # Process donation on S700
  post '/api/process_donation' do
    content_type :json
    
    begin
      data = JSON.parse(request.body.read)
      reader_id = data['reader_id']
      payment_intent_id = data['payment_intent_id']
      
      raise "Missing reader_id or payment_intent_id" unless reader_id && payment_intent_id
      
      puts "🎯 API: Processing donation on S700: #{payment_intent_id}"
      
      result = ReaderPaymentService.process_donation_on_reader(reader_id, payment_intent_id)
      
      result.to_json
      
    rescue StandardError => e
      puts "❌ API: Process donation error: #{e.message}"
      status 400
      { success: false, error: e.message }.to_json
    end
  end

  # Get donation status
  get '/api/donations/:id' do
    content_type :json
    
    begin
      payment_intent_id = params[:id]
      
      result = DonationService.get_donation_status(payment_intent_id)
      
      result.to_json
      
    rescue StandardError => e
      puts "❌ API: Get donation status error: #{e.message}"
      status 400
      { success: false, error: e.message }.to_json
    end
  end

  # Cancel donation
  delete '/api/donations/:id' do
    content_type :json
    
    begin
      payment_intent_id = params[:id]
      
      result = DonationService.cancel_donation(payment_intent_id)
      
      result.to_json
      
    rescue StandardError => e
      puts "❌ API: Cancel donation error: #{e.message}"
      status 400
      { success: false, error: e.message }.to_json
    end
  end

  # Discover readers
  get '/api/readers' do
    content_type :json
    
    begin
      result = TerminalService.discover_readers
      
      result.to_json
      
    rescue StandardError => e
      puts "❌ API: Discover readers error: #{e.message}"
      status 400
      { success: false, error: e.message }.to_json
    end
  end

  # Serve static files
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  # Serve assets
  get '/assets/*' do
    file_path = File.join(settings.public_folder, 'assets', params['splat'].first)
    if File.exist?(file_path)
      send_file file_path
    else
      status 404
      'Asset not found'
    end
  end

  # API 404 handler
  not_found do
    if request.path.start_with?('/api/')
      content_type :json
      { error: 'API endpoint not found' }.to_json
    else
      # Try to serve static file or return 404
      begin
        send_file File.join(settings.public_folder, 'index.html')
      rescue
        'Page not found'
      end
    end
  end

  post '/api/payments' do
    content_type :json
    PaymentController.new.process_payment(request)
  end
end

# Start the app if this file is run directly
if __FILE__ == $0
  port = ENV.fetch('PORT', 4242)
  DonationApp.run!(host: '0.0.0.0', port: port)
end