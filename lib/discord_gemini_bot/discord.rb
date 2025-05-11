# frozen_string_literal: true

require 'discordrb'

require 'discord_gemini_bot/conversation'
require 'discord_gemini_bot/gemini_api'

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

      puts "応答: #{message_event.message.server.name}##{message_event.message.channel.name} #{message_event.message.id}"

      # 試行中であることが分かりやすいように、「入力中」インジケーターを表示しておく
      message_event.message.channel.start_typing

      begin
        # リプライツリーを特定する ID
        reply_id = reply_tree_id bot, message_event.message

        # Gemini での会話
        Conversation.push_user_text reply_id, message_event.message.content
        gemini_response = GeminiAPI.generate_content(
          GeminiAPI::Models::Gemini_2_0_Flash,
          Conversation.gemini_request(reply_id)
        )
        response_text = Conversation.push_model_text reply_id, gemini_response

        # Discord に Gemini の応答を送り返す
        sent_message = message_event.respond response_text, false, nil, nil, nil, message_event.message, nil

        # リプライツリーを特定できるように、botの返信 Message ID を保存しておく
        @replay_tree_cache ||= {}
        @replay_tree_cache[sent_message.id] = reply_id
      rescue StandardError => e
        message_event.respond 'エラーが発生しました', false, nil, nil, nil, message_event.message, nil
        raise e
      end
    end

    bot.run true

    bot.online

    bot.join
  end

  # リプライツリーを特定する ID を返す
  def reply_tree_id(bot, message)
    follow_reply = true

    loop do
      unless message.referenced_message.nil?
        message = message.referenced_message
        next if follow_reply
      end

      # リプライツリーは1回だけ辿る
      follow_reply = false

      # bot自身の投稿なら、その投稿をキーにしてリプライツリーを特定する
      if message.author.id == bot.profile.id
        @replay_tree_cache ||= {}
        id = @replay_tree_cache[message.id]
        return id unless id.nil?

        # 紐づいたリプライツリーが見つからなければ、しょうがないので新しいリプライツリーということにしておく
        return message.id
      end

      # 返信ではなかった場合、新しいリプライツリー
      return message.id
    end
  end

  # DISCORD_BOT_TOKENを取得
  def bot_token
    k = ENV.fetch('DISCORD_BOT_TOKEN', nil)
    raise ArgumentError, 'DISCORD_BOT_TOKENが未設定' if k.nil?

    k
  end
end
