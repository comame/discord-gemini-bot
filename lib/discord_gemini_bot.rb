# frozen_string_literal: true

require 'typed_struct'
require 'net/http'

require 'discord_gemini_bot/conversation'
require 'discord_gemini_bot/gemini_api'

conversation_id = 'test'
model = GeminiAPI::Models::Gemini_2_0_Flash

req = Conversation.push_user_text conversation_id, '以降渡す英語を日本語に訳してください。'
res = GeminiAPI.generate_content model, req
Conversation.push_model_text conversation_id, res
p res

req = Conversation.push_user_text conversation_id, 'I went to the park with my friends yesterday. '
res = GeminiAPI.generate_content model, req
Conversation.push_model_text conversation_id, res

p res
