require 'twilio-ruby'
require 'sinatra'
require 'sinatra/json'
require 'dotenv'
require 'faker'
require 'rack/contrib'

# Load environment configuration
Dotenv.load

# Set public folder
set :public_folder, 'public'

# Parse JSON Body parts into params
use ::Rack::PostBodyContentTypeParser

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
        TWILIO_SYNC_SERVICE_SID: ENV['TWILIO_SYNC_SERVICE_SID'],
        TWILIO_CONFIGURATION_SID: ENV['TWILIO_CONFIGURATION_SID']
    }.to_json
end

# Generate an Access Token for an application user - it generates a random
# username for the client requesting a token, and takes a device ID as a query
# parameter.
get '/token' do
  # Create a random username for the client
  identity = Faker::Internet.user_name

  # Create an access token which we will sign and return to the client
  token = Twilio::JWT::AccessToken.new ENV['TWILIO_ACCOUNT_SID'],
  ENV['TWILIO_API_KEY'], ENV['TWILIO_API_SECRET'], 3600, identity

  # Grant the access token Video capabilities (if available)
  if ENV['TWILIO_CONFIGURATION_SID']
    grant = Twilio::JWT::AccessToken::ConversationsGrant.new
    grant.configuration_profile_sid = ENV['TWILIO_CONFIGURATION_SID']
    token.add_grant grant
  end

  # Grant the access token Chat capabilities (if available)
  if ENV['TWILIO_CHAT_SERVICE_SID']

    # Create the Chat Grant
    grant = Twilio::JWT::AccessToken::IpMessagingGrant.new
    grant.service_sid = ENV['TWILIO_CHAT_SERVICE_SID']
    token.add_grant grant
  end
  
  # Grant the access token Sync capabilities (if available)
  if ENV['TWILIO_SYNC_SERVICE_SID']

    # Create the Sync Grant
    grant = Twilio::JWT::AccessToken::SyncGrant.new
    grant.service_sid = ENV['TWILIO_SYNC_SERVICE_SID']
    token.add_grant grant
  end
  # Generate the token and send to client
  json :identity => identity, :token => token.to_jwt
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
  service = client.notify.v1.services(
    ENV['TWILIO_NOTIFICATION_SERVICE_SID']
  )

  begin
    binding = service.bindings.create(
      endpoint: params[:endpoint],
      identity: params[:identity],
      binding_type: params[:BindingType],
      address: params[:Address]
    )
    response = {
      message: 'Binding created!',
    }
    json response
  rescue Twilio::REST::TwilioException => e
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
  service = client.notify.v1.services(
    ENV['TWILIO_NOTIFICATION_SERVICE_SID']
  )

  begin
    binding = service.notifications.create(
      identity: params[:identity],
      body: 'Hello, ' + params[:identity] + '!'
    )
    response = {
      message: 'Notification Sent!',
    }
    json response
  rescue Twilio::REST::TwilioException => e
    puts e.message
    status 500
    response = {
      message: "Failed to send notification: #{e.message}",
      error: e.message
    }
    json response
  end
end