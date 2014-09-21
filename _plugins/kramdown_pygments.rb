# This class is a plugin for kramdown, to make it use pygments instead of coderay
# It has nothing to do with Jekyll, it is simply used by the custom converter below
module Kramdown
  module Converter
    class PygmentsHtml < Html

      begin
        require 'pygments'
        require 'mini_magick'
      rescue LoadError
        STDERR.puts 'You are missing a library required for syntax highlighting. Please run:'
        STDERR.puts '  $ [sudo] gem install pygments mini_magick'
        raise FatalException.new("Missing dependency: Pygments")
      end

      def convert_codeblock(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr)
        code = pygmentize(el.value, lang)
        code_attr = {}
        code_attr['class'] = "language-#{lang}" if lang
        "#{' '*indent}<div class=\"highlight\"><pre#{html_attributes(attr)}><code#{html_attributes(code_attr)}>#{code}</code></pre></div>\n"
      end

      def convert_codespan(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr)
        code = pygmentize(el.value, lang)
        if lang
          attr['class'] = "highlight"
          if attr.has_key?('class')
            attr['class'] += " language-#{lang}"
          else
            attr['class'] = "language-#{lang}"
          end
        end
        "<code#{html_attributes(attr)}>#{code}</code>"
      end

      def convert_img(el, indent)
        image = MiniMagick::Image.open el.attr['src']
        width = image[:width]
        unless el.attr['src'].match(/R-/).nil?
          width /= 2
        end
        "<figure>
          <a class='post-image' rel='post-image' href='#{el.attr['src']}'>
            <img#{html_attributes(el.attr)} width=#{width} />
          </a>
          <figcaption>#{el.attr['alt']}</figcaption>
        </figure>"
      end

      def pygmentize(code, lang)
        if lang
          Pygments.highlight(code,
            :lexer => lang,
            :options => { :startinline => true, :encoding => 'utf-8', :nowrap => true })
        else
          escape_html(code)
        end
      end
    end
  end
end

# This class is the actual custom Jekyll converter.
class Jekyll::Converters::Markdown::KramdownPygments

  def initialize(config)
    require 'kramdown'
    @config = config
  rescue LoadError
    STDERR.puts 'You are missing a library required for Markdown. Please run:'
    STDERR.puts '  $ [sudo] gem install kramdown'
    raise FatalException.new("Missing dependency: kramdown")
  end

  def convert(content)
    html = Kramdown::Document.new(content, {
        :auto_ids             => @config['kramdown']['auto_ids'],
        :footnote_nr          => @config['kramdown']['footnote_nr'],
        :entity_output        => @config['kramdown']['entity_output'],
        :toc_levels           => @config['kramdown']['toc_levels'],
        :smart_quotes         => @config['kramdown']['smart_quotes'],
        :input                => @config['kramdown']['input']
    }).to_pygments_html
    return html;
  end
end
