require 'fieldhand/network_errors'
require 'fieldhand/options'
require 'fieldhand/response_parser'
require 'cgi'
require 'net/http'
require 'uri'

module Fieldhand
  # An abstraction over interactions with an OAI-PMH repository, handling requests, responses and paginating over
  # results using a resumption token.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#FlowControl
  class Paginator
    attr_reader :uri, :logger, :timeout, :http

    # Return a new paginator for the given repository base URI and optional logger and timeout.
    #
    # The URI can be passed as either a `URI` or something that can be parsed as a URI such as a string.
    #
    # The logger will default to a null logger appropriate to this platform and timeout will default to 60 seconds.
    def initialize(uri, logger_or_options = {})
      @uri = uri.is_a?(::URI) ? uri : URI(uri)

      options = Options.new(logger_or_options)
      @logger = options.logger
      @timeout = options.timeout

      @http = ::Net::HTTP.new(@uri.host, @uri.port)
      @http.read_timeout = @timeout
      @http.open_timeout = @timeout
      @http.use_ssl = true if @uri.scheme == 'https'
    end

    # Return an `Enumerator` of items retrieved from the repository with the given `verb` and `query`, parsed with the
    # given `parser_class`.
    #
    # The query defaults to an empty hash but will be merged with the given `verb` when making requests to the
    # repository.
    #
    # Expects the `parser_class` to respond to `items`, returning an `Enumerable` list of items that will be yielded to
    # the caller.
    #
    # Raises a `ProtocolError` for any errors in the response.
    #
    # Fieldhand attempts to handle all flow control for the user using resumption tokens from the response so they only
    # need handle lazy enumerators and not worry about pagination and underlying network requests.
    #
    # # Examples
    #
    # ```
    # paginator = Fieldhand::Paginator.new('http://www.example.com/oai')
    # paginator.items('ListRecords', Fieldhand::ListRecordsParser).take(10_000)
    # #=> [#<Fieldhand::Record: ...>, ...]
    # ```
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#FlowControl
    def items(verb, parser_class, query = {})
      return enum_for(:items, verb, parser_class, query) unless block_given?

      loop do
        response_parser = parse_response(query.merge('verb' => verb))
        parser_class.new(response_parser).items.each do |item|
          yield item
        end

        break unless response_parser.resumption_token

        logger.debug('Fieldhand') { "Resumption token for #{verb}: #{response_parser.resumption_token}" }
        query = { 'resumptionToken' => response_parser.resumption_token }
      end
    end

    private

    def parse_response(query = {})
      response = request(query)
      raise ResponseError, response unless response.is_a?(::Net::HTTPSuccess)

      response_parser = ResponseParser.new(response.body)
      response_parser.errors.each do |error|
        raise error
      end

      response_parser
    end

    def request(query = {})
      request_uri = uri.dup
      request_uri.query = encode_query(query)

      logger.info('Fieldhand') { "GET #{request_uri}" }
      http.get(request_uri.request_uri)
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
