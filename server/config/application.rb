require 'sinatra'
require 'sinatra/activerecord'
require 'stripe'
require_relative 'config/database'
require_relative 'config/stripe'

class Application < Sinatra::Base
  configure do
    set :database_file, 'config/database.yml'
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET'] || 'super_secret'
  end

  # Load routes
  Dir[File.join(__dir__, 'routes', '*.rb')].each { |file| require file }

  # Error handling
  error do
    status 500
    'Internal Server Error'
  end

  not_found do
    status 404
    'Not Found'
  end
end