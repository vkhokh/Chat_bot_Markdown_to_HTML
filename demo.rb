# frozen_string_literal: true

require "pp"
require_relative "lib/our_web_gem"

markdown = <<~MARKDOWN
  # Demo Title

  Use **bold**, *italic*, [docs](https://example.com) and `puts`.

  - first item
  - second item

  > A short quote

  ```ruby
  puts "Hello from the demo"
  ```
MARKDOWN

ast = OurWebGem.parse(markdown)
html = OurWebGem.to_html(markdown)

puts "SOURCE MARKDOWN:"
puts markdown
puts

puts "AST:"
pp ast
puts

puts "HTML:"
puts html
