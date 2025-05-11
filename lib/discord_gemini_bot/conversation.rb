# frozen_string_literal: true

require 'discord_gemini_bot/conversation'

module Conversation
  DefaultPrompt = "あなたは Discord の bot です。以下にユーザーからの入力を渡すため、上限 140 字を目安に回答を生成してください。\n\n---\n\n"

  module_function

  def gemini_request(id)
    GeminiAPI::Types::GenerateContentRequest.new(
      contents: @contents[id],
      generation_config: GeminiAPI::Types::GenerationConfig.new(
        max_output_tokens: 140
      )
    )
  end

  def push_user_text(id, text)
    @contents = {} if @contents.nil?

    is_first_prompt = @contents[id].nil?
    @contents[id] = [] if is_first_prompt

    # 会話初めなら、初期プロンプトを与える
    prompt = text
    prompt = DefaultPrompt + text if is_first_prompt

    c = GeminiAPI::Types::Content.new(
      role: GeminiAPI::Types::ContentRole::User,
      parts: [
        GeminiAPI::Types::Part.new(text: prompt)
      ]
    )
    @contents[id] << c
  end

  # モデルからの応答を保存する。モデルからの応答を文字列として返す
  def push_model_text(id, generate_content_response)
    @contents = {} if @contents.nil?
    @contents[id] = [] if @contents[id].nil?

    res = String.new

    generate_content_response.candidates.each do |candidate|
      unless [GeminiAPI::Types::FinishReason::Stop, GeminiAPI::Types::FinishReason::MaxTokens].include?(candidate.finish_reason)
        puts 'geminiが不正なレスポンスを返した'
        pp generate_content_response
        next
      end
      next unless candidate.content.role == GeminiAPI::Types::ContentRole::Model

      @contents[id] << candidate.content
      candidate.content.parts.each do |part|
        res << part.text
        res << "\n"
      end
    end

    res
  end
end
