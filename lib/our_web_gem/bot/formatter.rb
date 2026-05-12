# frozen_string_literal: true

module OurWebGem
  module Bot
    class Formatter
      MAX_MESSAGE_LENGTH = 4000

      def self.start_message
        <<~TEXT
          Привет! Я бот для конвертации Markdown в HTML.

          Я могу превратить такой текст:

          # Заголовок
          **Жирный текст**

          в HTML-код.

          Команды:
          /convert - начать конвертацию
          /example - показать пример
          /history - показать последний Markdown-запрос
          /repeat - повторить последний HTML-результат
          /clear - очистить историю
          /help - справка
        TEXT
      end

      def self.help_message
        <<~TEXT
          Я конвертирую Markdown-текст в HTML и запоминаю твой последний запрос.

          Как пользоваться:
          1. Напиши /convert
          2. Отправь Markdown-текст
          3. Я верну готовый HTML-код

          Команды:
          /convert - начать конвертацию Markdown в HTML
          /example - показать пример Markdown и результата
          /history - показать последний Markdown-запрос
          /repeat - заново показать последний HTML-результат
          /clear - очистить историю пользователя
          /help - показать справку

          Пример Markdown:
          # Заголовок

          Это **жирный текст**.
        TEXT
      end

      def self.convert_message
        <<~TEXT
          Отправь Markdown-текст, который нужно превратить в HTML.

          Например:
          # Привет

          Это **жирный текст**.
        TEXT
      end

      def self.example_message
        <<~TEXT
          Пример работы:

          Markdown:

          # Мой сайт

          Это **главная страница**.

          - Главная
          - О нас
          - Контакты

          HTML:

          <h1>Мой сайт</h1>

          <p>Это <strong>главная страница</strong>.</p>

          <ul>
            <li>Главная</li>
            <li>О нас</li>
            <li>Контакты</li>
          </ul>

          Попробуй сам: напиши /convert.
        TEXT
      end

      def self.unknown_command_message
        <<~TEXT
          Я не понял команду.

          Напиши /convert, чтобы начать конвертацию, или /help, чтобы посмотреть справку.
        TEXT
      end

      def self.no_history_message
        <<~TEXT
          У тебя пока нет сохранённого запроса.

          Напиши /convert и отправь Markdown-текст.
        TEXT
      end

      def self.history_cleared_message
        "История очищена. Можешь начать заново через /convert."
      end

      def self.format_history(markdown)
        format_long_text("Твой последний Markdown-запрос:\n\n#{markdown}")
      end

      def self.format_repeat(html)
        format_long_text("Твой последний HTML-результат:\n\n#{html}")
      end

      def self.format_html(html)
        return "Не получилось получить HTML." if html.nil? || html.strip.empty?

        format_long_text("Готово! HTML:\n\n#{html}")
      end

      def self.error_message
        <<~TEXT
          Произошла ошибка при обработке сообщения.

          Попробуй ещё раз или напиши /convert.
        TEXT
      end

      def self.format_long_text(text)
        if text.length > MAX_MESSAGE_LENGTH
          "#{text[0...MAX_MESSAGE_LENGTH]}\n\nСообщение слишком большое, я обрезал результат."
        else
          text
        end
      end
    end
  end
end