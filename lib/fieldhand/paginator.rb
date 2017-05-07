require 'cgi'
require 'net/http'
require 'uri'
require 'ox'
require 'fieldhand/logger'

module Fieldhand
  NetworkError = ::Class.new(::StandardError)
  ProtocolError = ::Class.new(::StandardError)
  BadArgumentError = ::Class.new(ProtocolError)
  BadResumptionTokenError = ::Class.new(ProtocolError)
  BadVerbError = ::Class.new(ProtocolError)
  CannotDisseminateFormatError = ::Class.new(ProtocolError)
  IdDoesNotExistError = ::Class.new(ProtocolError)
  NoRecordsMatchError = ::Class.new(ProtocolError)
  NoMetadataFormatsError = ::Class.new(ProtocolError)
  NoSetHierarchyError = ::Class.new(ProtocolError)

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

    def items(verb, path, query = {})
      return enum_for(:items, verb, path, query) unless block_given?

      loop do
        document = ::Ox.parse(request(query.merge('verb' => verb)))

        document.root.locate('error').each do |error|
          convert_error(error)
        end

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

    def convert_error(error)
      case error['code']
      when 'badArgument' then raise BadArgumentError, error.text
      when 'badResumptionToken' then raise BadResumptionTokenError, error.text
      when 'badVerb' then raise BadVerbError, error.text
      when 'cannotDisseminateFormat' then raise CannotDisseminateFormatError, error.text
      when 'idDoesNotExist' then raise IdDoesNotExistError, error.text
      when 'noRecordsMatch' then raise NoRecordsMatchError, error.text
      when 'noMetadataFormats' then raise NoMetadataFormatsError, error.text
      when 'noSetHierarchy' then raise NoSetHierarchyError, error.text
      end
    end

    def encode_query(query = {})
      query.map { |k, v| ::CGI.escape(k) << '=' << ::CGI.escape(v) }.join('&')
    end
  end
end
