# frozen_string_literal: true

require 'typed_struct'
require 'net/http'

module GeminiAPI
  Models = {
    gemini_2_0_flash: 'gemini-2.0-flash'
  }.freeze

  BaseURI = 'https://generativelanguage.googleapis.com/v1beta'

  module Types
    module ContentRole
      User = :user
      Model = :model
    end

    module FinishReason
      Stop = :STOP
    end

    class Part < TypedStruct
      define :text, :string
    end

    class Content < TypedStruct
      define :parts, [Part]
      define :role, :symbol, allow: 'nil', json: ',omitempty' # ContentRole
    end

    class Candidate < TypedStruct
      define :content, Content
      define :finish_reason, :symbol, json: 'finishReason,omitempty' # FinishReason
    end

    class GenerateContentRequest < TypedStruct
      define :contents, [Content]
    end

    class Error < TypedStruct
      define :code, :int
      define :message, :string
      define :status, :string
    end

    class GenerateContentResponse < TypedStruct
      define :candidates, [Candidate]
      define :error, Error, allow: 'nil', json: ',omitempty'
    end
  end

  module_function

  def generate_content(model, generate_content_request)
    path = "/models/#{model}:generateContent"
    post path, generate_content_request, Types::GenerateContentResponse
  end

  def post(path, body, response_type)
    uri = URI("#{BaseURI}#{path}")
    headers = {
      'Content-Type' => 'application/json'
    }

    req = Net::HTTP::Post.new("#{uri.path}?key=#{api_key}", headers)
    req.body = TypedSerialize::JSON.marshal body

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    res = http.request(req)
    TypedSerialize::JSON.unmarshal(res.body, response_type)
  end

  def api_key
    ENV.fetch('GEMINI_API_KEY', nil)
  end
end

module Conversation
  module_function

  def push_user_text(id, text)
    @contents = {} if @contents.nil?
    @contents[id] = [] if @contents[id].nil?

    c = GeminiAPI::Types::Content.new(
      role: GeminiAPI::Types::ContentRole::User,
      parts: [
        GeminiAPI::Types::Part.new(text: text)
      ]
    )
    @contents[id] << c

    GeminiAPI::Types::GenerateContentRequest.new(
      contents: @contents[id]
    )
  end

  def push_model_text(id, generate_content_response)
    @contents = {} if @contents.nil?
    @contents[id] = [] if @contents[id].nil?

    last_pushed = nil
    generate_content_response.candidates.each do |candidate|
      continue unless candidate.finish_reason == GeminiAPI::Types::FinishReason::Stop
      continue unless candidate.content.role == GeminiAPI::Types::ContentRole::Model

      @contents[id] << candidate.content
      last_pushed = candidate.content
    end

    last_pushed
  end
end

conversation_id = 'test'
model = GeminiAPI::Models[:gemini_2_0_flash]

req = Conversation.push_user_text conversation_id, '以降渡す英語を日本語に訳してください。'
res = GeminiAPI.generate_content model, req
Conversation.push_model_text conversation_id, res
p res

req = Conversation.push_user_text conversation_id, 'I went to the park with my friends yesterday. '
res = GeminiAPI.generate_content model, req
Conversation.push_model_text conversation_id, res

p res
