require_relative 'server/app'

if __FILE__ == $0
  port = ENV.fetch('PORT', 4242)
  DonationApp.run!(host: '0.0.0.0', port: port)
end
