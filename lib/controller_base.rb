require 'active_support'
require 'erb'
require_relative './session'
require_relative './params'
require_relative './flash'
require_relative './url_helper'

class ControllerBase

  include URLHelper

  class DoubleRenderError < StandardError
  end

  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
    @already_built_response = false
    @flash = Flash.new(@req)
  end

  def flash
    @flash || Flash.new(@req)
  end

  def invoke_action(name)
    self.send(name)
    render name unless already_built_response?
  end

  def session
    @session ||= Session.new(req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise DoubleRenderError.new "Already built response" if already_built_response?
    @already_built_response = true
    @res.status = 302
    @res.header["location"] = url
    session.store_session(res)
    flash.store_flash(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, type)
    raise DoubleRenderError.new "Already built response" if already_built_response?
    @res.content_type = type
    @res.body = content
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(@res)
  end

  def render(template_name)
    controller_name = underscore(self.class.to_s)
    template = ERB.new(File.read("views/#{controller_name}/#{template_name}.html.erb"))
    content = template.result(binding)
    render_content(content, "text/html")
  end

  private

    # In case active support isn't cooperating
    def underscore(camel_cased_word)
      return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
      word = camel_cased_word.to_s.gsub(/::/, '/')
      word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1 && '_'}#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

end
