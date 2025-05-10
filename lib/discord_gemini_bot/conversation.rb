# frozen_string_literal: true

require 'discord_gemini_bot/conversation'

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
