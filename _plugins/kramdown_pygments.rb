# This class is a plugin for kramdown, to make it use pygments instead of coderay
# It has nothing to do with Jekyll, it is simply used by the custom converter below
module Kramdown
  module Converter
    class Html
      begin
        require 'json'
        require 'net/http'
      rescue LoadError
        STDERR.puts 'You are missing a library required for syntax highlighting. Please run:'
        raise FatalException.new("Missing dependency: Pygments")
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

      # def convert_codeblock(el, indent)
      #   attr = el.attr.dup
      #   lang = extract_code_language!(attr)
      #   code = pygmentize(el.value, lang)
      #   code_attr = {}
      #   code_attr['class'] = "language-#{lang}" if lang
      #   "#{' '*indent}<div class=\"highlight\"><pre#{html_attributes(attr)}><code#{html_attributes(code_attr)}>#{code}</code></pre></div>\n"
      # end

      # def convert_codespan(el, indent)
      #   attr = el.attr.dup
      #   lang = extract_code_language!(attr)
      #   code = pygmentize(el.value, lang)
      #   if lang
      #     attr['class'] = "highlight"
      #     if attr.has_key?('class')
      #       attr['class'] += " language-#{lang}"
      #     else
      #       attr['class'] = "language-#{lang}"
      #     end
      #   end
      #   "<span#{html_attributes(attr)} class='codespan'>#{code}</span>"
      # end
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
        src = el.attr['src']
        if src['qiniudn']
          image_info_uri = URI "#{src}?imageInfo"
          image_info = JSON.parse(Net::HTTP.get image_info_uri)
          width = image_info['width']
          height = image_info['height']
          unless src.match(/R-/).nil?
            width /= 2
            height /= 2
          end
          img_max_width = 720
          if width > img_max_width
            ratio = width.to_f / img_max_width
            width = img_max_width
            height = (height / ratio).to_i
          end
        end
        # add water mark
        el.attr['src'] = "#{src}-watermark"
        unless el.attr['alt'].empty?
          figcaption = "<figcaption><i class='icon-pencil'></i>#{el.attr['alt']}</figcaption>"
        end
        "<figure>
          <a class='post-image' rel='post-image' href='#{el.attr['src']}'>
            <img#{html_attributes(el.attr)} width=#{width} />
          </a>
          #{figcaption}
        </figure>"
      end

    end
  end
end
