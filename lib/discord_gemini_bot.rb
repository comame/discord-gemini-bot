# frozen_string_literal: true

require 'typed_struct'
require 'net/http'

require 'discord_gemini_bot/discord'

$stdout.sync = true
Discord.start
