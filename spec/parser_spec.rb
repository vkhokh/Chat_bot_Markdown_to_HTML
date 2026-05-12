# frozen_string_literal: true

require_relative "../lib/our_web_gem"

RSpec.describe OurWebGem::Parser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    it "parses headings and inline formatting" do
      markdown = "# Hello\n\nUse **bold**, *italics*, [docs](https://example.com) and `puts`."

      expect(parser.parse(markdown)).to eq(
        [
          {
            type: :heading,
            level: 1,
            children: [{ type: :text, value: "Hello" }]
          },
          {
            type: :paragraph,
            children: [
              { type: :text, value: "Use " },
              { type: :strong, children: [{ type: :text, value: "bold" }] },
              { type: :text, value: ", " },
              { type: :emphasis, children: [{ type: :text, value: "italics" }] },
              { type: :text, value: ", " },
              {
                type: :link,
                url: "https://example.com",
                children: [{ type: :text, value: "docs" }]
              },
              { type: :text, value: " and " },
              { type: :code_inline, value: "puts" },
              { type: :text, value: "." }
            ]
          }
        ]
      )
    end

    it "parses lists, blockquotes and fenced code blocks" do
      markdown = <<~MARKDOWN
        - first
        - second

        > Quoted line

        ```ruby
        puts "Hello"
        ```
      MARKDOWN

      expect(parser.parse(markdown)).to eq(
        [
          {
            type: :list,
            ordered: false,
            children: [
              { type: :list_item, children: [{ type: :text, value: "first" }] },
              { type: :list_item, children: [{ type: :text, value: "second" }] }
            ]
          },
          {
            type: :blockquote,
            children: [
              {
                type: :paragraph,
                children: [{ type: :text, value: "Quoted line" }]
              }
            ]
          },
          {
            type: :code_block,
            language: "ruby",
            value: "puts \"Hello\""
          }
        ]
      )
    end
  end
end

RSpec.describe OurWebGem do
  describe ".to_html" do
    it "converts markdown to html through the parser and renderer" do
      markdown = "# Title\n\n1. First\n2. Second"

      expect(described_class.to_html(markdown)).to eq(
        "<h1>Title</h1>\n<ol><li>First</li><li>Second</li></ol>"
      )
    end
  end
end
