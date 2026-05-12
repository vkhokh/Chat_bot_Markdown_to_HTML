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
          /convert — начать конвертацию
          /example — показать пример
          /help — справка
        TEXT
      end

      def self.help_message
        <<~TEXT
          Я конвертирую Markdown-текст в HTML.

          Как пользоваться:
          1. Напиши /convert
          2. Отправь Markdown-текст
          3. Я верну готовый HTML-код

          Команды:
          /convert — начать конвертацию Markdown в HTML
          /example — показать пример Markdown и результата
          /help — показать справку

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

      def self.format_html(html)
        return "Не получилось получить HTML." if html.nil? || html.strip.empty?

        text = "Готово! HTML:\n\n#{html}"

        if text.length > MAX_MESSAGE_LENGTH
          "#{text[0...MAX_MESSAGE_LENGTH]}\n\nСообщение слишком большое, я обрезал результат."
        else
          text
        end
      end

      def self.error_message
        <<~TEXT
          Произошла ошибка при обработке сообщения.

          Попробуй ещё раз или напиши /convert.
        TEXT
      end
    end
  end
end