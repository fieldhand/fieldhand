require 'cgi'
require 'net/http'
require 'uri'
require 'ox'
require 'fieldhand/logger'

module Fieldhand
  NetworkError = Class.new(StandardError)

  # An abstraction over interactions with an OAI-PMH repository, handling requests, responses and paginating over
  # results using a resumption token.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#FlowControl
  class Paginator
    attr_reader :uri, :logger, :http

    def initialize(uri, logger = Logger.null)
      @uri = uri.is_a?(URI) ? uri : URI(uri)
      @logger = logger
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true if uri.scheme == 'https'
    end

    def items(verb, path, query = {})
      return enum_for(:items, verb, path, query) unless block_given?

      loop do
        document = Ox.parse(request(query.merge('verb' => verb)))
        document.root.locate(path).each do |item|
          yield item
        end

        resumption_token = document.root.locate('?/resumptionToken/^String').first
        break unless resumption_token

        logger.debug('Fieldhand') { "Resumption token for #{verb}: #{resumption_token}" }
        query = { 'resumptionToken' => resumption_token }
      end
    end

    private

    def request(query = {})
      request_uri = uri.dup
      request_uri.query = encode_query(query)

      logger.info('Fieldhand') { "GET #{request_uri}" }
      http.get(request_uri.request_uri).body
    rescue ::Timeout::Error => e
      raise NetworkError, "timeout requesting #{query}: #{e}"
    rescue => e
      raise NetworkError, "error requesting #{query}: #{e}"
    end

    def encode_query(query = {})
      query.map { |k, v| CGI.escape(k) << '=' << CGI.escape(v) }.join('&')
    end
  end
end
