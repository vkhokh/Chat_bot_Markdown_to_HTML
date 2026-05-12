# frozen_string_literal: true

module OurWebGem
  module Bot
    class UserState
      DEFAULT_STATE = :idle

      def initialize
        @states = {}
      end

      def get(chat_id)
        @states.fetch(chat_id, DEFAULT_STATE)
      end

      def set(chat_id, state)
        @states[chat_id] = state
      end

      def reset(chat_id)
        @states.delete(chat_id)
      end
    end
  end
end