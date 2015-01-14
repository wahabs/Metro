require 'webrick'
require 'json'

class Flash

  # flash class handles all clearing

  def initialize(req)
    flash_cookie = req.cookies.find { |cookie| cookie.name == '_rails_lite_app_flash' }
    @flash_data = {}
    @flash_now = {}

    if flash_cookie
      JSON.parse(flash_cookie.value).each do |key, val|
        @flash_now[key] = val # if we get info from a cookie, we don't want to preserve it after this
      end
    end

  end

  # The [] and []= methods only apply to the @flash, calling flash.now[:key]
  # automatically accesses @flash_now

  def now
    @flash_now || {}
  end

  def [](key)
    @flash_now[key.to_s] || @flash_now[key.to_sym] || @flash_data[key.to_s]
  end

  def []=(key, val)
    @flash_data[key.to_s] = val # if we get info from a user (via controller) we want to store it into a cookie
  end

  def store_flash(res)
    cookie = WEBrick::Cookie.new('_rails_lite_app_flash', @flash_data.to_json)
    cookie.path = "/"
    res.cookies << cookie
  end

end
