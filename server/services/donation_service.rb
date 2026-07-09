require 'stripe'

class DonationService
  class << self
    def create_donation(amount, metadata = {})
      puts "💰 Creating a donation of $#{amount / 100}.00"
      
      begin
        # Create a new donation record
        donation = Donation.create(amount: amount, metadata: metadata)
        
        puts "✅ Donation created successfully: #{donation.id}"
        
        {
          success: true,
          donation_id: donation.id,
          message: "Donation of $#{amount / 100}.00 created successfully."
        }
      rescue => e
        puts "❌ Failed to create donation: #{e.message}"
        
        {
          success: false,
          error: e.message,
          message: "Failed to create donation."
        }
      end
    end

    def retrieve_donation(donation_id)
      puts "🔍 Retrieving donation with ID: #{donation_id}"
      
      begin
        donation = Donation.find(donation_id)
        
        puts "✅ Donation retrieved: #{donation.inspect}"
        
        {
          success: true,
          donation: donation
        }
      rescue ActiveRecord::RecordNotFound
        puts "❌ Donation not found: #{donation_id}"
        
        {
          success: false,
          message: "Donation not found."
        }
      rescue => e
        puts "❌ Error retrieving donation: #{e.message}"
        
        {
          success: false,
          error: e.message,
          message: "Error retrieving donation."
        }
      end
    end

    def list_donations
      puts "📋 Listing all donations"
      
      donations = Donation.all
      
      puts "✅ Donations retrieved: #{donations.count} found."
      
      {
        success: true,
        donations: donations
      }
    end

    def create_donation_payment(amount, donor_name = 'Anonymous', message = '', event_name = '')
      puts "💝 Creating donation payment for #{donor_name}: $#{amount/100.0}"
      puts "   Event: #{event_name}" unless event_name.empty?
      
      begin
        payment_intent = Stripe::PaymentIntent.create({
          amount: amount,
          currency: 'usd',
          payment_method_types: ['card_present'],
          capture_method: 'automatic',
          description: "Donation from #{donor_name}#{event_name.empty? ? '' : " for #{event_name}"}",
          metadata: {
            donation: 'true',
            donor_name: donor_name,
            message: message,
            event_name: event_name,
            created_at: Time.now.to_s
          }
        })
        
        puts "✅ Donation payment created: #{payment_intent.id}"
        
        {
          success: true,
          payment_intent: payment_intent.to_h,
          donation_details: {
            amount: amount,
            amount_display: "$#{(amount/100.0).round(2)}",
            donor_name: donor_name,
            message: message,
            payment_id: payment_intent.id
          }
        }
        
      rescue Stripe::StripeError => e
        puts "❌ Donation creation failed: #{e.message}"
        
        {
          success: false,
          error: e.message
        }
      end
    end
    
    def cancel_donation(payment_intent_id)
      puts "🚫 Canceling donation: #{payment_intent_id}"
      
      begin
        payment_intent = Stripe::PaymentIntent.cancel(payment_intent_id)
        
        puts "✅ Donation canceled: #{payment_intent_id}"
        
        {
          success: true,
          payment_intent: payment_intent.to_h,
          message: "Donation canceled successfully"
        }
        
      rescue Stripe::StripeError => e
        puts "❌ Cancel donation failed: #{e.message}"
        
        {
          success: false,
          error: e.message
        }
      end
    end
    
    def get_donation_status(payment_intent_id)
      begin
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
        
        # Safe metadata access without dig method
        metadata = payment_intent.metadata || {}
        donor_name = metadata['donor_name'] || 'Anonymous'
        message = metadata['message'] || ''
        event_name = metadata['event_name'] || ''
        
        {
          success: true,
          payment_intent: payment_intent.to_h,
          status: payment_intent.status,
          amount: payment_intent.amount,
          amount_display: "$#{(payment_intent.amount/100.0).round(2)}",
          donor_name: donor_name,
          message: message,
          event_name: event_name,
          created_at: payment_intent.created
        }
        
      rescue Stripe::StripeError => e
        puts "❌ Get donation status failed: #{e.message}"
        {
          success: false,
          error: e.message
        }
      end
    end

    def get_daily_donations(date = Date.today)
      begin
        # Get donations for the specified date
        start_time = date.beginning_of_day.to_i
        end_time = date.end_of_day.to_i
        
        payment_intents = Stripe::PaymentIntent.list({
          created: {
            gte: start_time,
            lte: end_time
          },
          limit: 100
        })
        
        donations = payment_intents.data.select do |pi|
          pi.metadata&.dig('donation') == 'true'
        end
        
        total_amount = donations.sum(&:amount)
        successful_donations = donations.select { |d| d.status == 'succeeded' }
        
        {
          success: true,
          date: date.to_s,
          total_donations: donations.length,
          successful_donations: successful_donations.length,
          total_amount: total_amount,
          total_amount_display: "$#{(total_amount/100.0).round(2)}",
          donations: donations.map do |donation|
            {
              id: donation.id,
              amount: donation.amount,
              amount_display: "$#{(donation.amount/100.0).round(2)}",
              status: donation.status,
              donor_name: donation.metadata&.dig('donor_name') || 'Anonymous',
              message: donation.metadata&.dig('message') || '',
              created_at: Time.at(donation.created)
            }
          end
        }
        
      rescue Stripe::StripeError => e
        {
          success: false,
          error: e.message
        }
      end
    end
    
  end
end