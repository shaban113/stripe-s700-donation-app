require 'sinatra'
require 'json'
require_relative '../controllers/donation_controller'

class DonationApp < Sinatra::Base
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

  # Get daily donations summary
  get '/api/donations/daily/:date' do
    content_type :json

    begin
      date = Date.parse(params[:date])

      result = DonationService.get_daily_donations(date)

      result.to_json

    rescue StandardError => e
      puts "❌ API: Get daily donations error: #{e.message}"
      status 400
      { success: false, error: e.message }.to_json
    end
  end
end