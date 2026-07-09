class PaymentIntent
  include ActiveModel::Model

  attr_accessor :amount, :currency, :payment_method_types, :capture_method, :metadata

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :payment_method_types, presence: true
  validates :capture_method, presence: true

  def initialize(attributes = {})
    super
    @currency ||= 'usd'
    @payment_method_types ||= ['card_present']
    @capture_method ||= 'automatic'
    @metadata ||= {}
  end

  def create
    raise "Invalid PaymentIntent" unless valid?

    Stripe::PaymentIntent.create({
      amount: amount,
      currency: currency,
      payment_method_types: payment_method_types,
      capture_method: capture_method,
      metadata: metadata
    })
  end
end