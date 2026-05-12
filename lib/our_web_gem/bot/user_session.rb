# frozen_string_literal: true

module OurWebGem
  module Bot
    class UserSession
      DEFAULT_STATE = :idle

      attr_reader :state, :last_markdown, :last_html

      def initialize
        @state = DEFAULT_STATE
        @last_markdown = nil
        @last_html = nil
      end

      def waiting_for_markdown?
        @state == :waiting_for_markdown
      end

      def wait_for_markdown
        @state = :waiting_for_markdown
      end

      def reset_state
        @state = DEFAULT_STATE
      end

      def save_conversion(markdown, html)
        @last_markdown = markdown
        @last_html = html
      end

      def history?
        !@last_markdown.nil? && !@last_html.nil?
      end

      def clear_history
        @last_markdown = nil
        @last_html = nil
      end
    end
  end
end