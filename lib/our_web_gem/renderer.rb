# frozen_string_literal: true

module OurWebGem
  class Renderer
    def render(nodes)
      Array(nodes).map { |node| render_node(node) }.join("\n")
    end

    private

    def render_node(node)
      case node[:type]
      when :text
        escape_html(node[:value].to_s)
      when :paragraph
        "<p>#{render_children(node)}</p>"
      when :heading
        level = [[node[:level].to_i, 1].max, 6].min
        "<h#{level}>#{render_children(node)}</h#{level}>"
      when :strong
        "<strong>#{render_children(node)}</strong>"
      when :emphasis
        "<em>#{render_children(node)}</em>"
      when :link
        href = escape_attr(node[:url].to_s)
        "<a href=\"#{href}\">#{render_children(node)}</a>"
      when :list
        tag = node[:ordered] ? "ol" : "ul"
        items = Array(node[:children]).map { |child| render_node(child) }.join
        "<#{tag}>#{items}</#{tag}>"
      when :list_item
        "<li>#{render_children(node)}</li>"
      when :code_inline
        "<code>#{escape_html(node[:value].to_s)}</code>"
      when :code_block
        render_code_block(node)
      when :blockquote
        "<blockquote>#{render_children(node)}</blockquote>"
      else
        raise ArgumentError, "Unknown node type: #{node[:type].inspect}"
      end
    end

    def render_children(node)
      Array(node[:children]).map { |child| render_node(child) }.join
    end

    def render_code_block(node)
      code = escape_html(node[:value].to_s)

      if node[:language] && !node[:language].empty?
        lang = escape_attr(node[:language].to_s)
        "<pre><code class=\"language-#{lang}\">#{code}</code></pre>"
      else
        "<pre><code>#{code}</code></pre>"
      end
    end

    def escape_html(text)
      text
        .gsub("&", "&amp;")
        .gsub("<", "&lt;")
        .gsub(">", "&gt;")
    end

    def escape_attr(text)
      escape_html(text).gsub('"', "&quot;")
    end
  end
end