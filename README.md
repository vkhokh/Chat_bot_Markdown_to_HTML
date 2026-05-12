# OurWebGem

`OurWebGem` is a Ruby gem that converts Markdown to HTML through an internal AST
(abstract syntax tree). The project is split into two clear stages:

- `Markdown -> AST`
- `AST -> HTML`

This makes the code easier to test, extend, and reason about.

## What The Gem Can Do

The gem currently supports:

- headings (`# Heading`)
- paragraphs
- bold text (`**bold**`)
- italic text (`*italic*`)
- links (`[text](https://example.com)`)
- inline code (`` `puts` ``)
- fenced code blocks
- ordered lists
- unordered lists
- blockquotes

## Public API

The gem exposes three main methods:

```ruby
require_relative "lib/our_web_gem"

markdown = "# Hello\n\nUse **bold** and `puts`."

ast = OurWebGem.parse(markdown)
html = OurWebGem.render(ast)
full_result = OurWebGem.to_html(markdown)
```

### `OurWebGem.parse(markdown)`

Parses Markdown and returns the internal AST.

Example:

```ruby
OurWebGem.parse("# Hello")
# =>
# [
#   {
#     type: :heading,
#     level: 1,
#     children: [{ type: :text, value: "Hello" }]
#   }
# ]
```

### `OurWebGem.render(ast)`

Takes the internal AST and renders HTML.

Example:

```ruby
ast = [
  {
    type: :paragraph,
    children: [
      { type: :text, value: "Use " },
      { type: :code_inline, value: "puts" }
    ]
  }
]

OurWebGem.render(ast)
# => "<p>Use <code>puts</code></p>"
```

### `OurWebGem.to_html(markdown)`

Runs the full pipeline from Markdown to HTML.

```ruby
OurWebGem.to_html("# Hello")
# => "<h1>Hello</h1>"
```

## Demo

There is a ready-to-run demo file in the project root:

```bash
ruby demo.rb
```

The demo prints:

- the original Markdown
- the generated AST
- the final HTML

## Local Development

After cloning the repository, install dependencies:

```bash
bundle install
```

Then run the test suite:

```bash
bundle exec rspec
```

To run the same default task used in CI:

```bash
bundle exec rake
```

The default rake task runs:

- `RSpec` tests
- `RuboCop`

## CI

The project uses GitHub Actions for CI. The workflow configuration is stored in
`.github/workflows/main.yml`.

CI runs:

```bash
bundle exec rake
```

In practice, this means every CI run checks both:

- test correctness
- code style

## Project Structure

Main files:

- `lib/our_web_gem/parser.rb` - Markdown to AST parser
- `lib/our_web_gem/renderer.rb` - AST to HTML renderer
- `lib/our_web_gem.rb` - public API of the gem
- `spec/` - automated tests
- `demo.rb` - small demonstration script

## Notes

The internal AST is the contract between the parser and the renderer. Because of
that, both parts of the project can be developed and tested independently.

## License

The gem is distributed under the MIT License. See `LICENSE.txt` for details.
