class PaymentController
  require_relative '../services/reader_payment_service'
  require_relative '../services/donation_service'

  def process_payment(params, request)
    donation_amount = params[:amount].to_i

    if donation_amount <= 0
      return {
        status: 400,
        body: { success: false, message: 'Invalid donation amount' }
      }
    end

    reader_id = params[:reader_id]
    payment_service_response = ReaderPaymentService.enable_reader_payments(reader_id)

    if payment_service_response[:success]
      donation_service_response = DonationService.create_donation(amount: donation_amount)

      if donation_service_response[:success]
        return {
          status: 200,
          body: {
            success: true,
            message: 'Payment initiated successfully',
            donation_id: donation_service_response[:donation_id],
            payment_options: payment_service_response[:payment_options]
          }
        }
      else
        return {
          status: 500,
          body: { success: false, message: donation_service_response[:message] }
        }
      end
    else
      return {
        status: 500,
        body: { success: false, message: payment_service_response[:message] }
      }
    end
  end

  def get_payment_status(donation_id)
    donation_status = DonationService.get_donation_status(donation_id)

    if donation_status
      return {
        status: 200,
        body: { success: true, status: donation_status }
      }
    else
      return {
        status: 404,
        body: { success: false, message: 'Donation not found' }
      }
    end
  end
end