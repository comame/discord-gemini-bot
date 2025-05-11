# frozen_string_literal: true

module GeminiAPI
  module Models
    Gemini_2_0_Flash = 'gemini-2.0-flash'
  end

  BaseURI = 'https://generativelanguage.googleapis.com/v1beta'

  module Types
    module ContentRole
      User = :user
      Model = :model
    end

    module FinishReason
      Stop = :STOP
      MaxTokens = :MAX_TOKENS
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

    class GenerationConfig < TypedStruct
      define :max_output_tokens, :int, json: 'maxOutputTokens,omitempty'
    end

    class GenerateContentRequest < TypedStruct
      define :contents, [Content]
      define :generation_config, GenerationConfig, json: 'generationConfig,omitempty'
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
    k = ENV.fetch('GEMINI_API_KEY', nil)
    raise ArgumentError, 'GEMINI_API_KEYが未指定' if k.nil?

    k
  end
end
