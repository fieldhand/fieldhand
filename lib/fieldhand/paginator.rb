require 'uri'
require 'net/http'
require 'ox'

module Fieldhand
  NetworkError = Class.new(StandardError)

  class Paginator
    attr_reader :uri

    def initialize(uri)
      @uri = URI(uri)
    end

    def items(verb, tag, query = {})
      query.update('verb' => verb)

      Enumerator.new do |yielder|
        loop do
          document = Ox.parse(request(query))
          document.root.locate("#{verb}/#{tag}").each do |item|
            yielder << item
          end

          resumption_token = document.locate("OAI-PMH/#{verb}/resumptionToken[0]").first
          break unless resumption_token && resumption_token.text

          query.update('resumptionToken' => resumption_token.text)
        end
      end
    end

    private

    def request(query = {})
      request_uri = uri.dup
      request_uri.query = URI.encode_www_form(query)

      Net::HTTP.get(request_uri)
    rescue StandardError, ::Timeout::Error => e
      raise NetworkError, "error requesting #{query}: #{e}"
    end
  end
end
