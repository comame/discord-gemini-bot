start: bundle
	. ./.env && bundle exec ruby lib/discord_gemini_bot.rb

dev:
	bundle exec ruby lib/discord_gemini_bot.rb

bundle:
	bundle install
