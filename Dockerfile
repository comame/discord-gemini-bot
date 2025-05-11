FROM ruby:3.4.3-slim

WORKDIR /root
RUN apt-get update && apt-get install -y git g++ make

COPY ./discord_gemini_bot.gemspec /root/
COPY ./Gemfile /root/
COPY ./Gemfile.lock /root/
RUN gem install bundler && bundle install

COPY . /root/

CMD [ "/usr/local/bin/bundle", "exec", "ruby", "lib/discord_gemini_bot.rb" ]
