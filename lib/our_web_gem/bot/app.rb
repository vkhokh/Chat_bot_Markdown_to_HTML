# frozen_string_literal: true

require "telegram/bot"
require_relative "../"
require_relative "session_storage"
require_relative "formatter"

module OurWebGem
  module Bot
    class App
      def initialize(token)
        @token = token
        @sessions = SessionStorage.new
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
        text = extract_text_with_entities(message).strip
        session = @sessions.session_for(chat_id)

        case text
        when "/start"
          handle_start(bot, chat_id, session)
        when "/help"
          handle_help(bot, chat_id)
        when "/convert"
          handle_convert(bot, chat_id, session)
        when "/example"
          handle_example(bot, chat_id)
        when "/history"
          handle_history(bot, chat_id, session)
        when "/repeat"
          handle_repeat(bot, chat_id, session)
        when "/clear"
          handle_clear(bot, chat_id, session)
        else
          handle_text(bot, chat_id, text, session)
        end
      end

      def handle_start(bot, chat_id, session)
        session.reset_state
        send_message(bot, chat_id, Formatter.start_message)
      end

      def handle_help(bot, chat_id)
        send_message(bot, chat_id, Formatter.help_message)
      end

      def handle_convert(bot, chat_id, session)
        session.wait_for_markdown
        send_message(bot, chat_id, Formatter.convert_message)
      end

      def handle_example(bot, chat_id)
        send_message(bot, chat_id, Formatter.example_message)
      end

      def handle_history(bot, chat_id, session)
        if session.history?
          send_message(bot, chat_id, Formatter.format_history(session.last_markdown))
        else
          send_message(bot, chat_id, Formatter.no_history_message)
        end
      end

      def handle_repeat(bot, chat_id, session)
        if session.history?
          send_message(bot, chat_id, Formatter.format_repeat(session.last_html))
        else
          send_message(bot, chat_id, Formatter.no_history_message)
        end
      end

      def handle_clear(bot, chat_id, session)
        session.clear_history
        session.reset_state

        send_message(bot, chat_id, Formatter.history_cleared_message)
      end

      def handle_text(bot, chat_id, text, session)
        if session.waiting_for_markdown?
          convert_markdown(bot, chat_id, text, session)
        else
          send_message(bot, chat_id, Formatter.unknown_command_message)
        end
      end

      def convert_markdown(bot, chat_id, markdown, session)
        html = OurWebGem.to_html(markdown)

        session.save_conversion(markdown, html)
        session.reset_state

        send_message(bot, chat_id, Formatter.format_html(html))
      end

      def extract_text_with_entities(message)
        text = message.text.to_s

        return text if message.entities.nil? || message.entities.empty?

        restore_markdown_entities(text, message.entities)
      end

      def restore_markdown_entities(text, entities)
        result = text.dup
        sorted_entities = entities.sort_by(&:offset).reverse

        sorted_entities.each do |entity|
          start_index = entity.offset
          end_index = entity.offset + entity.length
          opening, closing = markdown_symbols_for(entity.type)

          next if opening.nil? || closing.nil?

          result.insert(end_index, closing)
          result.insert(start_index, opening)
        end

        result
      end

      def markdown_symbols_for(type)
        case type
        when "bold"
          ["**", "**"]
        when "italic"
          ["*", "*"]
        when "code"
          ["`", "`"]
        when "pre"
          ["```", "```"]
        when "strikethrough"
          ["~~", "~~"]
        else
          [nil, nil]
        end
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