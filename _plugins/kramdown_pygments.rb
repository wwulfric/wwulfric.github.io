# Customizes kramdown's HTML output: scrollable tables, code blocks and figures
module Kramdown
  module Converter
    class Html
      alias_method :original_convert_table, :convert_table
      def convert_table(el, indent)
        table_html = original_convert_table(el, indent)
        "#{' ' * indent}<div class=\"table-container\">\n#{table_html}#{' ' * indent}</div>\n"
      end

      def convert_codeblock(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr)
        hl_opts = {}
        highlighted_code = highlight_code(el.value, el.options[:lang] || lang, :block, hl_opts)

        if highlighted_code
          add_syntax_highlighter_to_class_attr(attr, lang || hl_opts[:default_lang])
          "#{' '*indent}<div #{html_attributes(attr)}>#{highlighted_code}#{' '*indent}</div>\n"
        else
          result = escape_html(el.value)
          result.chomp!
          if el.attr['class'].to_s =~ /\bshow-whitespaces\b/
            result.gsub!(/(?:(^[ \t]+)|([ \t]+$)|([ \t]+))/) do |m|
              suffix = ($1 ? '-l' : ($2 ? '-r' : ''))
              m.scan(/./).map do |c|
                case c
                when "\t" then "<span class=\"ws-tab#{suffix}\">\t</span>"
                when " " then "<span class=\"ws-space#{suffix}\">&#8901;</span>"
                end
              end.join('')
            end
          end
          code_attr = {}
          code_attr['class'] = "language-#{lang}" if lang
          "#{' '*indent}<pre#{html_attributes(attr)}><code#{html_attributes(code_attr)}>#{result}\n</code></pre>\n"
        end
      end

      def convert_codespan(el, indent)
        attr = el.attr.dup
        lang = extract_code_language(attr)
        hl_opts = {}
        result = highlight_code(el.value, lang, :span, hl_opts)
        if result
          add_syntax_highlighter_to_class_attr(attr, hl_opts[:default_lang])
        else
          result = escape_html(el.value)
        end
        attr['class'] = 'codespan'
        format_as_span_html('span', attr, result)
      end

      def convert_img(el, indent)
        el.attr['loading'] = 'lazy'
        el.attr['decoding'] = 'async'
        unless el.attr['alt'].to_s.empty?
          figcaption = "<figcaption><i class='icon-pencil'></i>#{el.attr['alt']}</figcaption>"
        end
        "<figure>
          <img#{html_attributes(el.attr)} />
          #{figcaption}
        </figure>"
      end
    end
  end
end
