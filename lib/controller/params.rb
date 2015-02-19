require 'uri'

class Params
  # uses initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  #
  # Route params should be passed in as a hash to `Params.new` as below:
  def initialize(req, route_params = {})
    @params = parse_www_encoded_form(req.query_string)
    @params = @params.merge(parse_www_encoded_form(req.body))
    @params = @params.merge(route_params)
  end

  def [](key)
    @params[key.to_s]
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private

  # user[address][street]=main&user[address][zip]=89436
  # will return { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)

    begin
      raise AttributeNotFoundError if www_encoded_form.nil?
      decoding = URI::decode_www_form(www_encoded_form)
    rescue AttributeNotFoundError
      return {}
    end

    params = {}

    decoding.each do |(key, val)|
      current = params
      parsing = parse_key(key)

      until parsing.length == 0
        key = parsing.shift
        current[key] ||= {}
        current = current[key] unless parsing.length == 0
      end

      current[key] = val
    end
    params
  end


  # user[address][street] returns ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end

end
