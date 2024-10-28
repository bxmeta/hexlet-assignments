# frozen_string_literal: true

# BEGIN
require 'uri'
require 'forwardable'

class Url
  extend Forwardable
  # include Comparable

  def_delegators :@uri, :scheme, :host, :port

  def initialize(url)
    @uri = URI.parse(url)
    @query_params = parse_query_params
  end

  def query_params
    @query_params
  end

  def parse_query_params
    return {} unless @uri.query
    @uri.query.split('&').each_with_object({}) do |item, params|
      key, value = item.split('=')
      params[key.to_sym] = value
    end
  end

  def query_param(key, default = nil)
    @query_params[key.to_sym] || default
  end

  def ==(other)
    return false unless other.is_a?(Url)
    scheme == other.scheme &&
      host == other.host &&
      port == other.port &&
      query_params == other.query_params
  end

end
# END