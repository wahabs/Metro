require 'webrick'
require 'json'

class Flash

  def initialize
    @flash = {}
    @clear_upon_request = false
  end

  def now
    @clear_upon_request = true
    self
  end

  def clear
    self = self.class.new
  end

  def [](key)
    @flash[key]
  end

  def []=(key, val)
    @flash[key] = val
  end

  def store_flash(res)
    res.cookies << WEBrick::Cookie.new('')
  end

end
