require 'uri'
module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
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
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
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

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end

  end
end
