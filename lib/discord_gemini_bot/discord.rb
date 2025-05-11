# frozen_string_literal: true

require 'discordrb'

module Discord
  module_function

  def start
    intent_message_content = 1 << 15
    bot = ::Discordrb::Bot.new(
      token: bot_token,
      intents: [:server_messages, intent_message_content]
    )

    bot.message do |message_event|
      bot_mentioned = message_event.message.mentions.any? { |user| user.id == bot.profile.id }
      replied_message = message_event.message.referenced_message

      if replied_message.nil?
        # 自分へのメンションならば応答
        next unless bot_mentioned
      else
        # 自分へのメンションあるいはリプライなら応答
        next unless bot_mentioned || replied_message.user.id == bot.profile.id
      end

      message_event.message.channel.start_typing
      message_event.respond 'hi!', false, nil, nil, nil, message_event.message, nil
    end

    bot.run true

    bot.online

    bot.join
  end

  # DISCORD_BOT_TOKENを取得
  def bot_token
    k = ENV.fetch('DISCORD_BOT_TOKEN', nil)
    raise ArgumentError, 'DISCORD_BOT_TOKENが未設定' if k.nil?

    k
  end
end
