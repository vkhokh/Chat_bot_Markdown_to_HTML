# frozen_string_literal: true

require_relative "../lib/our_web_gem"

RSpec.describe OurWebGem::Renderer do
  subject(:renderer) { described_class.new }

  it "renders heading" do
    ast = [
      {
        type: :heading,
        level: 1,
        children: [{ type: :text, value: "Hello" }]
      }
    ]

    expect(renderer.render(ast)).to eq("<h1>Hello</h1>")
  end

  it "renders inline code" do
    ast = [
      {
        type: :paragraph,
        children: [
          { type: :text, value: "Use " },
          { type: :code_inline, value: "puts" }
        ]
      }
    ]

    expect(renderer.render(ast)).to eq("<p>Use <code>puts</code></p>")
  end

  it "renders strong, emphasis and links inside a paragraph" do
    ast = [
      {
        type: :paragraph,
        children: [
          { type: :strong, children: [{ type: :text, value: "Bold" }] },
          { type: :text, value: " and " },
          { type: :emphasis, children: [{ type: :text, value: "italic" }] },
          { type: :text, value: " with " },
          {
            type: :link,
            url: "https://example.com/docs",
            children: [{ type: :text, value: "docs" }]
          }
        ]
      }
    ]

    expect(renderer.render(ast)).to eq(
      "<p><strong>Bold</strong> and <em>italic</em> with <a href=\"https://example.com/docs\">docs</a></p>"
    )
  end

  it "renders ordered and unordered lists" do
    ordered_ast = [
      {
        type: :list,
        ordered: true,
        children: [
          { type: :list_item, children: [{ type: :text, value: "First" }] },
          { type: :list_item, children: [{ type: :text, value: "Second" }] }
        ]
      }
    ]

    unordered_ast = [
      {
        type: :list,
        ordered: false,
        children: [
          { type: :list_item, children: [{ type: :text, value: "Apple" }] },
          { type: :list_item, children: [{ type: :text, value: "Banana" }] }
        ]
      }
    ]

    expect(renderer.render(ordered_ast)).to eq("<ol><li>First</li><li>Second</li></ol>")
    expect(renderer.render(unordered_ast)).to eq("<ul><li>Apple</li><li>Banana</li></ul>")
  end

  it "renders code block" do
    ast = [
      {
        type: :code_block,
        value: "puts 'Hello'"
      }
    ]

    expect(renderer.render(ast)).to eq("<pre><code>puts 'Hello'</code></pre>")
  end

  it "renders code block with language class" do
    ast = [
      {
        type: :code_block,
        language: "ruby",
        value: "puts 'Hello'"
      }
    ]

    expect(renderer.render(ast)).to eq("<pre><code class=\"language-ruby\">puts 'Hello'</code></pre>")
  end

  it "renders blockquote" do
    ast = [
      {
        type: :blockquote,
        children: [
          {
            type: :paragraph,
            children: [{ type: :text, value: "Quote" }]
          }
        ]
      }
    ]

    expect(renderer.render(ast)).to eq("<blockquote><p>Quote</p></blockquote>")
  end

  it "escapes html in text, code and link attributes" do
    ast = [
      {
        type: :paragraph,
        children: [
          { type: :text, value: "<b>Safe & sound</b>" },
          { type: :text, value: " " },
          { type: :code_inline, value: "<tag>&value" },
          { type: :text, value: " " },
          {
            type: :link,
            url: "https://example.com/?q=\"x\"&safe=true",
            children: [{ type: :text, value: "link" }]
          }
        ]
      }
    ]

    expect(renderer.render(ast)).to eq(
      "<p>&lt;b&gt;Safe &amp; sound&lt;/b&gt; <code>&lt;tag&gt;&amp;value</code> " \
      "<a href=\"https://example.com/?q=&quot;x&quot;&amp;safe=true\">link</a></p>"
    )
  end

  it "clamps heading level between 1 and 6" do
    low_level_ast = [{ type: :heading, level: 0, children: [{ type: :text, value: "Low" }] }]
    high_level_ast = [{ type: :heading, level: 10, children: [{ type: :text, value: "High" }] }]

    expect(renderer.render(low_level_ast)).to eq("<h1>Low</h1>")
    expect(renderer.render(high_level_ast)).to eq("<h6>High</h6>")
  end

  it "renders empty input" do
    expect(renderer.render([])).to eq("")
  end

  it "raises on unknown node" do
    ast = [{ type: :unknown }]

    expect { renderer.render(ast) }.to raise_error(ArgumentError)
  end
end
