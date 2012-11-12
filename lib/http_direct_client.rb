require 'httparty'

class HttpDirectClient
  include HTTParty

  def post(path, options={})
    jsonify_body!(options)
    self.class.post(path, options)
  end

  def delete(path, options={})
    jsonify_body!(options)
    self.class.delete(path, options)
  end

  def get(path, options={})
    jsonify_body!(options)
    self.class.get(path, options)
  end

  def jsonify_body!(options)
    options[:body] = options[:body].to_json if options[:body]
  end

end