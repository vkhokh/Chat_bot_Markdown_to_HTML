# frozen_string_literal: true

require_relative "our_web_gem/version"
require_relative "our_web_gem/parser"
require_relative "our_web_gem/renderer"

module OurWebGem
  class Error < StandardError; end

  def self.parse(markdown)
    Parser.new.parse(markdown)
  end

  def self.render(ast)
    Renderer.new.render(ast)
  end

  def self.to_html(markdown)
    render(parse(markdown))
  end
end
