class DonationController
  require 'sinatra'
  require_relative '../services/donation_service'

  class << self
    def create_donation
      donation_data = JSON.parse(request.body.read)
      amount = donation_data['amount']

      if amount.nil? || amount <= 0
        status 400
        return { success: false, message: 'Invalid donation amount' }.to_json
      end

      donation_service = DonationService.new
      result = donation_service.create_donation(amount)

      if result[:success]
        status 201
        result.to_json
      else
        status 500
        { success: false, message: result[:message] }.to_json
      end
    end

    def retrieve_donations
      donation_service = DonationService.new
      donations = donation_service.retrieve_donations

      if donations
        status 200
        donations.to_json
      else
        status 500
        { success: false, message: 'Failed to retrieve donations' }.to_json
      end
    end
  end
end