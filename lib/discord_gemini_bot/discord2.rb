# frozen_string_literal: true

require 'discordrb'

require 'discord_gemini_bot/discord'

module Discord2
  module_function

  def start
    intent_message_content = 1 << 15
    bot = ::Discordrb::Bot.new(
      token: Discord.bot_token,
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
end
