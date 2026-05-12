# frozen_string_literal: true

module OurWebGem
  class Parser
    BLOCKQUOTE_PATTERN = /\A\s*>\s?(?<content>.*)\z/
    FENCED_CODE_PATTERN = /\A```(?<language>\S+)?\s*\z/
    HEADING_PATTERN = /\A(?<markers>\#{1,6})\s+(?<content>.*)\z/
    ORDERED_LIST_PATTERN = /\A\s*\d+\.\s+(?<content>.+)\z/
    SPECIAL_CHARACTERS = ["\\", "`", "*", "_", "["].freeze
    UNORDERED_LIST_PATTERN = /\A\s*[-*+]\s+(?<content>.+)\z/

    def parse(markdown)
      parse_blocks(normalize(markdown).split("\n", -1))
    end

    private

    def normalize(markdown)
      markdown.to_s.gsub("\r\n", "\n").gsub("\r", "\n")
    end

    def parse_blocks(lines)
      nodes = []
      index = 0

      while index < lines.length
        if blank_line?(lines[index])
          index += 1
          next
        end

        node, index = parse_block(lines, index)
        nodes << node
      end

      nodes
    end

    def parse_block(lines, index)
      return parse_code_block(lines, index) if fenced_code_line?(lines[index])
      return parse_heading(lines, index) if heading_line?(lines[index])
      return parse_blockquote(lines, index) if blockquote_line?(lines[index])
      return parse_list(lines, index) if list_line?(lines[index])

      parse_paragraph(lines, index)
    end

    def parse_code_block(lines, index)
      match = FENCED_CODE_PATTERN.match(lines[index])
      language = match[:language]
      code_lines = []
      index += 1

      while index < lines.length && !fenced_code_line?(lines[index])
        code_lines << lines[index]
        index += 1
      end

      index += 1 if index < lines.length

      node = { type: :code_block, value: code_lines.join("\n") }
      node[:language] = language unless language.to_s.empty?
      [node, index]
    end

    def parse_heading(lines, index)
      match = HEADING_PATTERN.match(lines[index])
      node = {
        type: :heading,
        level: match[:markers].length,
        children: parse_inlines(match[:content].strip)
      }

      [node, index + 1]
    end

    def parse_blockquote(lines, index)
      quote_lines = []

      while index < lines.length
        if (match = BLOCKQUOTE_PATTERN.match(lines[index]))
          quote_lines << match[:content]
          index += 1
          next
        end

        break unless blank_line?(lines[index]) && next_line_blockquote?(lines, index)

        quote_lines << ""
        index += 1
      end

      [{ type: :blockquote, children: parse_blocks(quote_lines) }, index]
    end

    def parse_list(lines, index)
      ordered = ordered_list_line?(lines[index])
      items = []

      while index < lines.length
        content = ordered ? ordered_list_content(lines[index]) : unordered_list_content(lines[index])
        break unless content

        items << { type: :list_item, children: parse_inlines(content.strip) }
        index += 1
      end

      [{ type: :list, ordered: ordered, children: items }, index]
    end

    def parse_paragraph(lines, index)
      content_lines = []

      while index < lines.length && paragraph_line?(lines[index])
        content_lines << lines[index].strip
        index += 1
      end

      text = content_lines.join(" ")
      [{ type: :paragraph, children: parse_inlines(text) }, index]
    end

    def parse_inlines(text)
      nodes = []
      index = 0

      while index < text.length
        token = parse_inline_token(text, index)
        append_inline_token(nodes, token)
        index = token[:next_index]
      end

      nodes
    end

    def parse_inline_token(text, index)
      parse_escaped_character(text, index) ||
        parse_code_span(text, index) ||
        parse_strong(text, index) ||
        parse_emphasis(text, index) ||
        parse_link(text, index) ||
        parse_text_fragment(text, index)
    end

    def parse_escaped_character(text, index)
      return unless text[index] == "\\"

      if index + 1 >= text.length
        { text: "\\", next_index: index + 1 }
      else
        { text: text[index + 1], next_index: index + 2 }
      end
    end

    def parse_code_span(text, index)
      return unless text[index] == "`"

      closing = find_delimiter(text, "`", index + 1)
      return unless closing

      {
        node: { type: :code_inline, value: text[(index + 1)...closing] },
        next_index: closing + 1
      }
    end

    def parse_strong(text, index)
      parse_wrapped_node(text, index, "**", :strong) ||
        parse_wrapped_node(text, index, "__", :strong)
    end

    def parse_emphasis(text, index)
      parse_wrapped_node(text, index, "*", :emphasis) ||
        parse_wrapped_node(text, index, "_", :emphasis)
    end

    def parse_wrapped_node(text, index, delimiter, type)
      return unless text[index, delimiter.length] == delimiter

      closing = find_delimiter(text, delimiter, index + delimiter.length)
      return unless closing && closing > index + delimiter.length

      {
        node: {
          type: type,
          children: parse_inlines(text[(index + delimiter.length)...closing])
        },
        next_index: closing + delimiter.length
      }
    end

    def parse_link(text, index)
      return unless text[index] == "["

      label_end = find_delimiter(text, "]", index + 1)
      return unless label_end && text[label_end + 1] == "("

      url_end = find_delimiter(text, ")", label_end + 2)
      return unless url_end

      label = text[(index + 1)...label_end]
      url = text[(label_end + 2)...url_end]
      return if url.empty?

      {
        node: { type: :link, url: url, children: parse_inlines(label) },
        next_index: url_end + 1
      }
    end

    def parse_text_fragment(text, index)
      special_index = SPECIAL_CHARACTERS.map { |char| text.index(char, index) }.compact.min || text.length
      special_index = index + 1 if special_index == index

      { text: text[index...special_index], next_index: special_index }
    end

    def append_inline_token(nodes, token)
      return append_text_node(nodes, token[:text]) if token[:text]

      nodes << token[:node]
    end

    def append_text_node(nodes, text)
      return if text.empty?

      if nodes.last&.dig(:type) == :text
        nodes.last[:value] += text
      else
        nodes << { type: :text, value: text }
      end
    end

    def find_delimiter(text, delimiter, start_index)
      index = start_index

      while index < text.length
        position = text.index(delimiter, index)
        return unless position
        return position unless escaped?(text, position)

        index = position + 1
      end
    end

    def escaped?(text, index)
      backslashes = 0
      cursor = index - 1

      while cursor >= 0 && text[cursor] == "\\"
        backslashes += 1
        cursor -= 1
      end

      backslashes.odd?
    end

    def blank_line?(line)
      line.strip.empty?
    end

    def heading_line?(line)
      HEADING_PATTERN.match?(line)
    end

    def fenced_code_line?(line)
      FENCED_CODE_PATTERN.match?(line)
    end

    def blockquote_line?(line)
      BLOCKQUOTE_PATTERN.match?(line)
    end

    def list_line?(line)
      ordered_list_line?(line) || unordered_list_line?(line)
    end

    def ordered_list_line?(line)
      ORDERED_LIST_PATTERN.match?(line)
    end

    def unordered_list_line?(line)
      UNORDERED_LIST_PATTERN.match?(line)
    end

    def ordered_list_content(line)
      ORDERED_LIST_PATTERN.match(line)&.[](:content)
    end

    def unordered_list_content(line)
      UNORDERED_LIST_PATTERN.match(line)&.[](:content)
    end

    def next_line_blockquote?(lines, index)
      index + 1 < lines.length && blockquote_line?(lines[index + 1])
    end

    def paragraph_line?(line)
      !blank_line?(line) && !heading_line?(line) && !fenced_code_line?(line) &&
        !blockquote_line?(line) && !list_line?(line)
    end
  end
end
