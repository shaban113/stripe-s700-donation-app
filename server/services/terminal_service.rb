# Complete your server/services/terminal_service.rb
require 'stripe'

class TerminalService
  class << self
    def discover_readers(device_type: 'stripe_s700')
      puts "🔍 Discovering #{device_type} readers..."
      
      begin
        discovery = Stripe::Terminal::Reader.list({
          device_type: device_type,
          limit: 10
        })
        
        {
          success: true,
          readers: discovery.data.map(&:to_h)
        }
        
      rescue Stripe::StripeError => e
        {
          success: false,
          error: e.message
        }
      end
    end

    def initialize_terminal(reader_id)
      puts "Initializing terminal for Reader ID: #{reader_id}"
      # Additional initialization logic can be added here
    end

    def process_donation(reader_id, amount)
      puts "Processing donation of $#{amount / 100.0} on Reader ID: #{reader_id}"
      # Logic to create a payment intent and process the payment
      begin
        payment_intent = Stripe::PaymentIntent.create({
          amount: amount,
          currency: 'usd',
          payment_method_types: ['card_present'],
          capture_method: 'automatic',
          metadata: {
            reader_id: reader_id,
            donation_amount: amount.to_s
          }
        })

        puts "Payment Intent created: #{payment_intent.id}"
        return payment_intent
      rescue Stripe::StripeError => e
        puts "Error processing donation: #{e.message}"
        return nil
      end
    end

    def display_payment_status(reader_id, payment_intent_id)
      puts "Displaying payment status for Payment Intent ID: #{payment_intent_id} on Reader ID: #{reader_id}"
      # Logic to retrieve and display payment status
      begin
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
        puts "Payment Status: #{payment_intent.status}"
        return payment_intent.status
      rescue Stripe::StripeError => e
        puts "Error retrieving payment status: #{e.message}"
        return nil
      end
    end
  end
end