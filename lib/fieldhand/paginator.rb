require 'cgi'
require 'net/http'
require 'ox'
require 'uri'

module Fieldhand
  NetworkError = Class.new(StandardError)

  class Paginator
    attr_reader :uri, :http

    def initialize(uri)
      @uri = uri.is_a?(URI) ? uri : URI(uri)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true if uri.scheme == 'https'
    end

    def items(verb, path, query = {})
      return enum_for(:items, verb, path, query) unless block_given?

      query.update('verb' => verb)

      loop do
        document = Ox.parse(request(query))
        document.root.locate(path).each do |item|
          yield item
        end

        resumption_token = document.locate("OAI-PMH/#{verb}/resumptionToken[0]").first
        break unless resumption_token && resumption_token.text

        query.update('resumptionToken' => resumption_token.text)
      end
    end

    private

    def request(query = {})
      request_uri = uri.dup
      request_uri.query = query.map { |k, v|
        str = CGI.escape(k)
        str << '='
        str << CGI.escape(v)
      }.join('&')

      http.get(request_uri.request_uri).body
    rescue StandardError, ::Timeout::Error => e
      raise NetworkError, "error requesting #{query}: #{e}"
    end
  end
end
