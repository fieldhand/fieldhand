require 'fieldhand/datestamp'
require 'fieldhand/logger'
require 'ox'
require 'cgi'
require 'net/http'
require 'uri'

module Fieldhand
  NetworkError = ::Class.new(::StandardError)

  # An abstraction over interactions with an OAI-PMH repository, handling requests, responses and paginating over
  # results using a resumption token.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#FlowControl
  class Paginator
    attr_reader :uri, :logger, :http

    def initialize(uri, logger = Logger.null)
      @uri = uri.is_a?(::URI) ? uri : URI(uri)
      @logger = logger
      @http = ::Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true if @uri.scheme == 'https'
    end

    def items(verb, parser_class, query = {})
      return enum_for(:items, verb, parser_class, query) unless block_given?

      loop do
        parser = parser_class.new
        ::Ox.sax_parse(parser, request(query.merge('verb' => verb)))

        parser.items.each do |item|
          yield item
        end

        break unless parser.resumption_token

        logger.debug('Fieldhand') { "Resumption token for #{verb}: #{parser.resumption_token}" }
        query = { 'resumptionToken' => parser.resumption_token }
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
      query.map { |k, v| ::CGI.escape(k) << '=' << ::CGI.escape(v) }.join('&')
    end
  end
end
