class Kramdown::Converter::Html
  def convert_img(el, indent)
    "<em><img#{html_attributes(el.attr)} /></em>"
  end
end
