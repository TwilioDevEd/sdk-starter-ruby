require 'twilio-ruby'
require 'sinatra'
require 'sinatra/json'
require 'dotenv'
require 'faker'
require 'rack/contrib'
require 'facets/string/snakecase'

# Load environment configuration
Dotenv.load

# Set public folder
set :public_folder, 'public'

# Parse JSON Body parts into params
use ::Rack::PostBodyContentTypeParser

configure do
    enable :cross_origin
end

before do
    response.headers['Access-Control-Allow-Origin'] = '*'
end

# Render home page
get '/' do
    redirect '/index.html'
end

# Render video page
get '/video/' do
    redirect '/video/index.html'
end

# Render notify page
get '/notify/' do
    redirect '/notify/index.html'
end

# Render Chat page
get '/chat/' do
    redirect '/chat/index.html'
end

# Render sync page
get '/sync/' do
    redirect '/sync/index.html'
end

# Basic health check - check environment variables have been configured correctly
get '/config' do
    content_type :json
    {
        TWILIO_ACCOUNT_SID: ENV['TWILIO_ACCOUNT_SID'],
        TWILIO_NOTIFICATION_SERVICE_SID: ENV['TWILIO_NOTIFICATION_SERVICE_SID'],
        TWILIO_API_KEY: ENV['TWILIO_API_KEY']   ,
        TWILIO_API_SECRET: ENV['TWILIO_API_SECRET'] != '',
        TWILIO_CHAT_SERVICE_SID: ENV['TWILIO_CHAT_SERVICE_SID'],
        TWILIO_SYNC_SERVICE_SID: ENV['TWILIO_SYNC_SERVICE_SID'] || 'default'
    }.to_json
end

# Generate an Access Token for an application user - it generates a random
# username for the client requesting a token
get '/token' do
  # Create a random username for the client
  identity = Faker::Internet.user_name

  # Create an access token which we will sign and return to the client
  token = generate_token(identity)

  # Generate the token and send to client
  json :identity => identity, :token => token
end

# Generate an Access Token for an application user with the provided identity
post '/token' do
  identity = params[:identity]

  token = generate_token(identity)

  # Generate the token and send to client
  json :identity => identity, :token => token
end

# Notify - create a device binding from a POST HTTP request
post '/register' do

  # Authenticate with Twilio
  client = Twilio::REST::Client.new(
      ENV['TWILIO_API_KEY'],
      ENV['TWILIO_API_SECRET'],
      ENV['TWILIO_ACCOUNT_SID']
  )

  # Reference a valid notification service
  service = client.notify.services(
    ENV['TWILIO_NOTIFICATION_SERVICE_SID']
  )

  params_hash = snake_case_keys(params)
  params_hash = symbolize_keys(params_hash)

  begin
    binding = service.bindings.create(params_hash)
    response = {
      message: 'Binding created!',
    }
    json response
  rescue Twilio::REST::TwilioError => e
    puts e.message
    status 500
    response = {
      message: "Failed to create binding: #{e.message}",
      error: e.message
    }
    json response
  end
end

# Notify - send a notification from a POST HTTP request
post '/send-notification' do

  # Authenticate with Twilio
  client = Twilio::REST::Client.new(
      ENV['TWILIO_API_KEY'],
      ENV['TWILIO_API_SECRET'],
      ENV['TWILIO_ACCOUNT_SID']
  )

  # Reference a valid notification service
  service = client.notify.services(
    ENV['TWILIO_NOTIFICATION_SERVICE_SID']
  )

  params_hash = snake_case_keys(params)
  params_hash = symbolize_keys(params_hash)

  begin
    binding = service.notifications.create(params_hash)
    response = {
      message: 'Notification Sent!',
    }
    json response
  rescue Twilio::REST::TwilioError => e
    puts e.message
    status 500
    response = {
      message: "Failed to send notification: #{e.message}",
      error: e.message
    }
    json response
  end
end

def generate_token(identity)
  # Create an access token which we will sign and return to the client
  token = Twilio::JWT::AccessToken.new ENV['TWILIO_ACCOUNT_SID'],
  ENV['TWILIO_API_KEY'], ENV['TWILIO_API_SECRET'], identity: identity

  # Grant the access token Video capabilities (if available)
  grant = Twilio::JWT::AccessToken::VideoGrant.new
  token.add_grant grant

  # Grant the access token Chat capabilities (if available)
  if ENV['TWILIO_CHAT_SERVICE_SID']

    # Create the Chat Grant
    grant = Twilio::JWT::AccessToken::ChatGrant.new
    grant.service_sid = ENV['TWILIO_CHAT_SERVICE_SID']
    token.add_grant grant
  end

  # Create the Sync Grant
  sync_grant = Twilio::JWT::AccessToken::SyncGrant.new
  sync_grant.service_sid = ENV['TWILIO_SYNC_SERVICE_SID'] || 'default'
  token.add_grant sync_grant

  return token.to_jwt
end

def symbolize_keys(h)
  # Use the symbolize names argument of parse to convert String keys to Symbols
  return JSON.parse(JSON.generate(h), symbolize_names: true)
end

def snake_case_keys(h)
  newh = Hash.new
  h.keys.each do |key|
    newh[key.snakecase] = h[key]
  end
  return newh
end

# Ensure that the Sync Default Service is provisioned
def provision_sync_default_service()
  client = Twilio::REST::Client.new(ENV['TWILIO_API_KEY'], ENV['TWILIO_API_SECRET'], ENV['TWILIO_ACCOUNT_SID'])
  client.sync.services('default').fetch
end
provision_sync_default_service
