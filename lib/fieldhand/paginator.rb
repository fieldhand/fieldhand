require 'cgi'
require 'net/http'
require 'ox'
require 'uri'

module Fieldhand
  NetworkError = Class.new(StandardError)

  class Paginator
    attr_reader :uri

    def initialize(uri)
      @uri = uri.is_a?(URI) ? uri : URI(uri)
    end

    def items(verb, tag, query = {})
      return enum_for(:items, verb, tag, query) unless block_given?

      query.update('verb' => verb)

      loop do
        document = Ox.parse(request(query))
        document.root.locate("#{verb}/#{tag}").each do |item|
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
      request_uri.query = query.map { |k, v| [CGI.escape(k), CGI.escape(v)].join('=') }.join('&')

      Net::HTTP.get(request_uri)
    rescue StandardError, ::Timeout::Error => e
      raise NetworkError, "error requesting #{query}: #{e}"
    end
  end
end
