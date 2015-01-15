module URLHelper

  def link_to(body, url)
    "<a href='#{url}'>#{body}</a>"
  end

  def button_to(name, url, options = {})

    if options[:method].nil?
      hidden = ""
    else
      hidden = "<input type='hidden' name='_method' value='#{options[:method].to_s}'>"
    end

    "<form action='#{url}' method='post'>" +
    hidden +
    "<input type='submit' value='#{name}'>" +
    "</form>"
    # authenticity_token ...
  end

end
