# frozen_string_literal: true

require_relative "user_session"

module OurWebGem
  module Bot
    class SessionStorage
      def initialize
        @sessions = {}
      end

      def session_for(chat_id)
        @sessions[chat_id] ||= UserSession.new
      end

      def reset_state(chat_id)
        session_for(chat_id).reset_state
      end

      def clear_history(chat_id)
        session_for(chat_id).clear_history
      end
    end
  end
end