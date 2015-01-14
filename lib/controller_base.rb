require 'active_support'
require 'erb'
require_relative './session'
require_relative './params'

class ControllerBase

  class DoubleRenderError < StandardError
  end

  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
    @already_built_response = false
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
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    template = ERB.new(File.read("views/#{controller_name}/#{template_name}.html.erb"))
    content = template.result(binding)
    render_content(content, "text/html")
  end


end
