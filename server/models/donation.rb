class Donation
  include Mongoid::Document

  field :amount, type: Integer
  field :currency, type: String, default: 'usd'
  field :donor_name, type: String
  field :donor_email, type: String
  field :created_at, type: Time, default: ->{ Time.now }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :donor_name, presence: true
  validates :donor_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def formatted_amount
    sprintf('%.2f', amount / 100.0)
  end
end