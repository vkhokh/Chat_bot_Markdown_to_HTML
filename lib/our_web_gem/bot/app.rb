# frozen_string_literal: true

require "telegram/bot"
require_relative "../"
require_relative "user_state"
require_relative "formatter"

module OurWebGem
  module Bot
    class App
      def initialize(token)
        @token = token
        @user_state = UserState.new
      end

      def run
        Telegram::Bot::Client.run(@token) do |bot|
          bot.listen do |message|
            handle_message(bot, message)
          rescue StandardError => e
            handle_error(bot, message, e)
          end
        end
      end

      private

      def handle_message(bot, message)
        return unless message.respond_to?(:text)
        return if message.text.nil?

        chat_id = message.chat.id
        text = message.text.strip

        case text
        when "/start"
          handle_start(bot, chat_id)
        when "/help"
          handle_help(bot, chat_id)
        when "/convert"
          handle_convert(bot, chat_id)
        when "/example"
          handle_example(bot, chat_id)
        else
          handle_text(bot, chat_id, text)
        end
      end

      def handle_start(bot, chat_id)
        @user_state.reset(chat_id)
        send_message(bot, chat_id, Formatter.start_message)
      end

      def handle_help(bot, chat_id)
        send_message(bot, chat_id, Formatter.help_message)
      end

      def handle_convert(bot, chat_id)
        @user_state.set(chat_id, :waiting_for_markdown)
        send_message(bot, chat_id, Formatter.convert_message)
      end

      def handle_example(bot, chat_id)
        send_message(bot, chat_id, Formatter.example_message)
      end

      def handle_text(bot, chat_id, text)
        if @user_state.get(chat_id) == :waiting_for_markdown
          convert_markdown(bot, chat_id, text)
        else
          send_message(bot, chat_id, Formatter.unknown_command_message)
        end
      end

      def convert_markdown(bot, chat_id, markdown)
        html = OurWebGem.to_html(markdown)

        @user_state.reset(chat_id)

        send_message(bot, chat_id, Formatter.format_html(html))
      end

      def handle_error(bot, message, error)
        puts "Ошибка: #{error.class} - #{error.message}"

        return unless message.respond_to?(:chat)

        send_message(bot, message.chat.id, Formatter.error_message)
      end

      def send_message(bot, chat_id, text)
        bot.api.send_message(
          chat_id: chat_id,
          text: text
        )
      end
    end
  end
end