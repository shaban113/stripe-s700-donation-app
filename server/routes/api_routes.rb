require 'sinatra'
require 'json'
require_relative '../controllers/donation_controller'
require_relative '../controllers/payment_controller'
require_relative '../controllers/reader_controller'

class ApiRoutes
  def self.setup_routes(app)
    app.post '/api/donations', DonationController.new.method(:create)
    app.get '/api/donations/:id', DonationController.new.method(:show)
    app.post '/api/payments', PaymentController.new.method(:process_payment)
    app.post '/api/readers/:reader_id/payments', ReaderController.new.method(:enable_reader_payments)
  end
end

class DonationApp < Sinatra::Base
  # Connection token for Terminal
  post '/api/connection_token' do
    content_type :json

    begin
      puts "🎫 API: Creating connection token for donation app..."

      connection_token = Stripe::Terminal::ConnectionToken.create

      puts "✅ API: Connection token created successfully"

      { secret: connection_token.secret }.to_json
    rescue Stripe::StripeError => e
      puts "❌ API: Connection token error: #{e.message}"
      status 400
      { error: e.message }.to_json
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
end

ApiRoutes.setup_routes(app)