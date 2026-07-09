require 'stripe'

class ReaderPaymentService
  class << self
    
    def enable_reader_payments(reader_id, custom_amount)
      puts "🎯 AUTO-START CUSTOMER SELF-SERVICE: Creating custom donation amount..."
      puts "   Reader ID: #{reader_id}, Custom Amount: #{custom_amount}"
      
      begin
        # Get reader details
        reader = Stripe::Terminal::Reader.retrieve(reader_id)
        
        # Clear any previous state first
        clear_reader_for_customer_use(reader_id, reader)
        
        # Create a payment intent for the custom amount
        puts "   💰 Creating payment workflow for custom amount: $#{custom_amount}..."
        
        create_custom_payment_workflow(reader_id, custom_amount)
        
      rescue Stripe::StripeError => e
        puts "❌ Auto-start customer payments failed: #{e.message}"
        
        {
          success: false,
          error: e.message,
          message: "Auto-start failed - try manual activation"
        }
      end
    end
    
    def clear_reader_for_customer_use(reader_id, reader)
      puts "   🧹 Preparing S700 for auto-start customer mode..."
      
      begin
        # Cancel any existing operations
        Stripe::Terminal::Reader.cancel_action(reader_id)
        puts "   ✅ Previous operations cleared"
        sleep(2)
        
        # Set initial display
        Stripe::Terminal::Reader.set_reader_display(
          reader_id,
          {
            type: 'cart',
            cart: {
              currency: 'usd',
              tax: 0,
              total: 0,
              line_items: [
                {
                  description: 'Auto-Starting Customer Mode...',
                  amount: 0,
                  quantity: 1
                }
              ]
            }
          }
        )
        
        puts "   ✅ S700 prepared for auto-start"
        
      rescue Stripe::StripeError => e
        puts "   ℹ️ Clear state: #{e.message}"
      end
    end
    
    def create_custom_payment_workflow(reader_id, amount)
      puts "   💰 AUTO-START: Creating payment for $#{amount}..."
      
      begin
        # Create a payment intent for the custom amount
        payment_intent = Stripe::PaymentIntent.create({
          amount: amount,
          currency: 'usd',
          payment_method_types: ['card_present'],
          capture_method: 'automatic',
          metadata: {
            auto_start_customer_mode: 'true',
            preset_amount: amount.to_s,
            reader_id: reader_id
          }
        })
        
        puts "   ✅ AUTO-CREATED payment: #{payment_intent.id} for $#{amount/100}.00"
        
        # Process the payment on the reader immediately
        process_result = Stripe::Terminal::Reader.process_payment_intent(
          reader_id,
          {
            payment_intent: payment_intent.id,
            process_config: {
              enable_customer_cancellation: true,
              skip_tipping: false
            }
          }
        )
        
        puts "   ✅ AUTO-START: S700 now showing $#{amount/100}.00 payment interface!"
        puts "   📺 Customer can pay immediately or cancel for other amounts"
        
        return {
          success: true,
          message: "AUTO-START SUCCESS: Customer can pay $#{amount/100}.00 immediately",
          method: "auto_start_custom_payment",
          active_payment: {
            amount: amount,
            payment_intent_id: payment_intent.id,
            display_amount: "$#{amount/100}.00"
          },
          customer_instructions: [
            "🎯 AUTO-STARTED: S700 ready for immediate payment!",
            "💳 Current amount: $#{amount/100}.00",
            "✅ To pay this amount: Present your card now",
            "🚫 For different amount: Cancel and ask staff"
          ],
          staff_instructions: [
            "🎯 AUTO-START SUCCESS: Customer payment active",
            "📺 S700 shows $#{amount/100}.00 payment interface",
            "✅ Customer can pay immediately",
            "🔄 If customer cancels: Create new payment with different amount"
          ]
        }
        
      rescue Stripe::StripeError => e
        puts "   ❌ Auto-start custom payment workflow failed: #{e.message}"
        
        return {
          success: false,
          message: "Auto-start failed: #{e.message}",
          method: "auto_start_failed",
          recommendation: [
            "❌ Auto-start unsuccessful",
            "🔄 Try manual customer activation",
            "🔌 Check S700 connection",
            "🧹 Use Clear Reader State if needed"
          ]
        }
      end
    end
    
    def process_donation_on_reader(reader_id, payment_intent_id)
      puts "🎯 Processing donation on S700 reader: #{reader_id}"
      
      begin
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
        amount = payment_intent.amount
        
        process_result = Stripe::Terminal::Reader.process_payment_intent(
          reader_id,
          {
            payment_intent: payment_intent_id,
            process_config: {
              enable_customer_cancellation: true,
              skip_tipping: false
            }
          }
        )
        
        puts "✅ Donation payment active on S700"
        
        {
          success: true,
          message: "Donation payment active on S700",
          donation_details: {
            amount: amount,
            amount_display: "$#{amount/100.0}",
            payment_id: payment_intent_id
          }
        }
        
      rescue Stripe::StripeError => e
        puts "❌ Process donation failed: #{e.message}"
        
        {
          success: false,
          error: e.message
        }
      end
    end
    
  end
end