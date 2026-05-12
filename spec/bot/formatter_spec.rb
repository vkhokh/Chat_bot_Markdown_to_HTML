# frozen_string_literal: true

require "our_web_gem/bot/formatter"

RSpec.describe OurWebGem::Bot::Formatter do
  describe ".start_message" do
    it "contains main bot commands" do
      result = described_class.start_message

      expect(result).to include("/convert")
      expect(result).to include("/example")
      expect(result).to include("/history")
      expect(result).to include("/repeat")
      expect(result).to include("/clear")
      expect(result).to include("/help")
    end

    it "does not contain cancel command" do
      result = described_class.start_message

      expect(result).not_to include("/cancel")
    end
  end

  describe ".help_message" do
    it "explains how to use the bot" do
      result = described_class.help_message

      expect(result).to include("Markdown")
      expect(result).to include("HTML")
      expect(result).to include("/convert")
    end
  end

  describe ".convert_message" do
    it "asks user to send markdown text" do
      result = described_class.convert_message

      expect(result).to include("Отправь Markdown-текст")
    end
  end

  describe ".example_message" do
    it "contains markdown and html examples" do
      result = described_class.example_message

      expect(result).to include("Markdown")
      expect(result).to include("HTML")
      expect(result).to include("<h1>")
      expect(result).to include("<ul>")
    end
  end

  describe ".unknown_command_message" do
    it "suggests available commands" do
      result = described_class.unknown_command_message

      expect(result).to include("/convert")
      expect(result).to include("/help")
    end
  end

  describe ".no_history_message" do
    it "returns message about empty history" do
      result = described_class.no_history_message

      expect(result).to include("нет сохранённого запроса")
    end
  end

  describe ".history_cleared_message" do
    it "returns message about cleared history" do
      result = described_class.history_cleared_message

      expect(result).to include("История очищена")
    end
  end

  describe ".format_history" do
    it "formats markdown history" do
      result = described_class.format_history("# Hello")

      expect(result).to include("Твой последний Markdown-запрос:")
      expect(result).to include("# Hello")
    end
  end

  describe ".format_repeat" do
    it "formats html history" do
      result = described_class.format_repeat("<h1>Hello</h1>")

      expect(result).to include("Твой последний HTML-результат:")
      expect(result).to include("<h1>Hello</h1>")
    end
  end

  describe ".format_html" do
    it "formats html result" do
      result = described_class.format_html("<h1>Hello</h1>")

      expect(result).to include("Готово! HTML:")
      expect(result).to include("<h1>Hello</h1>")
    end

    it "returns message for empty html" do
      result = described_class.format_html("")

      expect(result).to eq("Не получилось получить HTML.")
    end

    it "returns message for nil html" do
      result = described_class.format_html(nil)

      expect(result).to eq("Не получилось получить HTML.")
    end
  end

  describe ".error_message" do
    it "returns error text" do
      result = described_class.error_message

      expect(result).to include("Произошла ошибка")
    end
  end
end