class ReaderController
  require_relative '../services/reader_payment_service'

  def initialize
    @reader_payment_service = ReaderPaymentService
  end

  def enable_payments(reader_id)
    result = @reader_payment_service.enable_reader_payments(reader_id)
    if result[:success]
      status 200
      json result
    else
      status 400
      json result
    end
  end

  def clear_reader(reader_id)
    @reader_payment_service.clear_reader_for_customer_use(reader_id)
    status 204
  end
end