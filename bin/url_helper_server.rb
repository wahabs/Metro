require 'webrick'
require 'active_support'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class Dog
  attr_reader :name, :owner

  def self.all
    @dog ||= []
  end

  def initialize(params = {})
    params ||= {}
    @name, @owner = params["name"], params["owner"]
  end

  def errors
    @errors ||= []
  end

  def valid?
    unless @owner.present?
      errors << "Owner can't be blank"
      return false
    end

    unless @name.present?
      errors << "Name can't be blank"
      return false
    end
    true
  end

  def save
    return false unless valid?

    Dog.all << self
    true
  end

  def inspect
    { name: name, owner: owner }.inspect
  end
end

class DogsController < ControllerBase
  def create
    @dog = Dog.new(params["dog"])
    if @dog.save
      flash[:notice] = "Saved dog successfully"
      redirect_to "/dogs"
    else
      flash.now[:errors] = @dog.errors
      render :new
    end
  end

  def index
    @dogs = Dog.all
    render :index
  end

  def new
    @dog = Dog.new
    render :new
  end

  def show
    render :show
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/dogs$"), DogsController, :index
  get Regexp.new("^/dogs/new$"), DogsController, :new
  get Regexp.new("^/dogs/(?<id>\\d+)$"), DogsController, :show
  post Regexp.new("^/dogs$"), DogsController, :create
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  router.run(req, res)
end

trap('INT') { server.shutdown }
server.start