module URLHelper

  def link_to(body, url)
    "<a href=\"#{url}\">#{body}</a>"
  end

  def button_to(name, url, options = {})
    options[:method] ||= :post
    "<form method=\"post\" action=\"#{url}\" class=\"button_to\">" +
    "<input type=\"hidden\" name=\"_method\" value=\"#{options[:method].to_s}\" >" +
    "<input type=\"submit\" value=\"#{name}\">" +
    "</form>"
    # authenticity_token ...
  end

end
