# frozen_string_literal: true

require 'ed25519'
require 'typed_struct'

# Interaction を処理する用のクラス。使うかと思ったけど使わなかった...
module DiscordInteraction
  module_function

  # interaction を処理する
  def handle_interaction(interaction_request)
    interaction_response = nil
    case interaction_request.type
    when Discord::Types::InteractionTypePing
      interaction_response = Discord::Types::InteractionResponse.new(
        type: Discord::Types::InteractionCallbackTypePong
      )
    end

    raise 'interaction_response が nil' if interaction_response.nil?

    interaction_response
  end

  # 署名の検証を行う
  def verify_signature(signature_ed25519, signature_timestamp, body_string)
    public_key.verify decode_hex(signature_ed25519), signature_timestamp + body_string
  rescue StandardError => e
    puts "DiscordのAPI呼び出しの認証に失敗: #{e.message}"
    false
  end

  # hex文字列をそのまま文字列に変換。署名の検証に使う。
  def decode_hex(hex)
    [hex].pack('H*')
  end

  # DISCORD_PUBLIC_KEYを取得
  def public_key
    k_hex = ENV.fetch('DISCORD_PUBLIC_KEY', nil)
    raise ArgumentError, 'DISCORD_PUBLIC_KEYが未設定' if k_hex.nil?

    k_str = decode_hex k_hex
    Ed25519::VerifyKey.new k_str
  end

  # DISCORD_APPLICATION_IDを取得
  def application_id
    k = ENV.fetch('DISCORD_APPLICATION_ID', nil)
    raise ArgumentError, 'DISCORD_APPLICATION_IDが未設定' if k.nil?

    k
  end

  # DISCORD_BOT_TOKENを取得
  def bot_token
    k = ENV.fetch('DISCORD_BOT_TOKEN', nil)
    raise ArgumentError, 'DISCORD_BOT_TOKENが未設定' if k.nil?

    k
  end
end

module Discord
  module Types
    class InteractionData < TypedStruct
      define :id, :string
      define :name, :string
      define :type, :int # Unknown
    end

    InteractionTypePing = 1

    class Interaction < TypedStruct
      define :id, :string
      define :application_id, :string
      define :type, :int # InteractionType
      define :data, InteractionData
    end

    InteractionCallbackTypePong = 1

    class InteractionResponse < TypedStruct
      define :type, :int # InteractionCallbackType
      define :data, :any, json: ',omitempty'
    end
  end
end
