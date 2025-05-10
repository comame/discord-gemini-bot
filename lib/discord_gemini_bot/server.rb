# frozen_string_literal: true

require 'sinatra'

require 'discord_gemini_bot/discord'

def request_header(request, name)
  n = "HTTP_#{name.upcase.gsub('-', '_')}"
  request.env.fetch(n, '')
end

def start_app
  set :port, 8080
  disable :run
  set :environment, 'production'

  post '/gemini/interactions' do
    signature = request_header request, 'X-Signature-Ed25519'
    timestamp = request_header request, 'X-Signature-Timestamp'

    req_body = request.body.read

    verified = Discord.verify_signature signature, timestamp, req_body
    unless verified
      status 401 # Unauthorized
      return
    end

    interaction_request = TypedSerialize::JSON.unmarshal req_body, Discord::Types::Interaction
    pp interaction_request

    TypedSerialize::JSON.marshal Discord.handle_interaction(interaction_request)
  end

  Sinatra::Application.run!
end
