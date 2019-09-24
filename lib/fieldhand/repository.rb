require 'fieldhand/arguments'
require 'fieldhand/get_record_parser'
require 'fieldhand/identify_parser'
require 'fieldhand/list_identifiers_parser'
require 'fieldhand/list_metadata_formats_parser'
require 'fieldhand/list_records_parser'
require 'fieldhand/list_sets_parser'
require 'fieldhand/options'
require 'fieldhand/paginator'
require 'forwardable'
require 'uri'

module Fieldhand
  # A repository is a network accessible server that can process the 6 OAI-PMH requests.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html
  class Repository
    attr_reader :uri, :logger_or_options

    extend Forwardable
    def_delegators :paginator, :logger, :timeout, :headers

    # Return a new repository with the given base URL and an optional logger, timeout, bearer token and headers.
    #
    # The base URL can be passed as a `URI` or anything that can be parsed as a URI such as a string.
    #
    # The retries and interval options are passed to the Paginator class.
    #
    # For backward compatibility, the second argument can either be a logger or a hash containing
    # a logger, timeout, retries, interval, bearer token and headers. Method calls are delgated to Paginator
    #
    # Defaults to using a null logger specific to this platform, a timeout of 60 seconds, no bearer token and no headers.
    def initialize(uri, logger_or_options = {})
      @uri = uri.is_a?(::URI) ? uri : URI(uri)

      @logger_or_options = logger_or_options
    end

    # Send an Identify request to the repository and return an `Identify` response.
    #
    # Raises a `NetworkError` if there is an issue contacting the repository or a `ProtocolError` if received in
    # response.
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify
    def identify
      paginator.items('Identify', IdentifyParser).first
    end

    # Send a ListMetadataFormats request to the repository (with an optional identifier) and return an `Enumerator` of
    # `MetadataFormat`s.
    #
    # Raises a `NetworkError` if there is an issue contacting the repository or a `ProtocolError` if received in
    # response.
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats
    def metadata_formats(identifier = nil)
      query = {}
      query['identifier'] = identifier if identifier

      paginator.items('ListMetadataFormats', ListMetadataFormatsParser, query)
    end

    # Send a ListSets request to the repository and return an `Enumerator` of `Set`s.
    #
    # Raises a `NetworkError` if there is an issue contacting the repository or a `ProtocolError` if received in
    # response.
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListSets
    def sets
      paginator.items('ListSets', ListSetsParser)
    end

    # Send a ListRecords request to the repository with optional arguments and return an `Enumerator` of `Records`s.
    #
    # The following arguments can be used:
    #
    # * :metadata_prefix - The prefix of the metadata format to be used for record metadata, defaults to "oai_dc"
    # * :from - A `Date`, `Time` or formatted string specifying a lower bound for datestamp-based selective harvesting
    # * :until - A `Date`, `Time` or formatted string specifying an upper bound for datestamp-based selective harvesting
    # * :set - A `Set` or string set spec which specifies set criteria for selective harvesting
    # * :resumption_token - A valid resumption token for resuming a previous request (note that Fieldhand typically
    #                       handles resumption internally so this should not be normally used)
    #
    # Raises a `NetworkError` if there is an issue contacting the repository or a `ProtocolError` if received in
    # response.
    #
    # # Examples
    #
    # ```
    # repository = Fieldhand::Repository.new('http://www.example.com/oai')
    # repository.records.each do |record|
    #   next if record.deleted?
    #
    #   puts record.metadata
    # end
    # ```
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListRecords
    def records(arguments = {})
      query = Arguments.new(arguments).to_query

      paginator.items('ListRecords', ListRecordsParser, query)
    end

    # Send a ListIdentifiers request to the repository with optional arguments and return an `Enumerator` of `Header`s.
    #
    # This supports the same arguments as `Fieldhand::Repository#records` but only returns record headers.
    #
    # Raises a `NetworkError` if there is an issue contacting the repository or a `ProtocolError` if received in
    # response.
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListIdentifiers
    def identifiers(arguments = {})
      query = Arguments.new(arguments).to_query

      paginator.items('ListIdentifiers', ListIdentifiersParser, query)
    end

    # Send a GetRecord request to the repository with the given identifier and optional metadata prefix and return a
    # `Record`.
    #
    # Supports passing a :metadata_prefix argument with a given metadata prefix which otherwise defaults to "oai_dc".
    #
    # Raises a `NetworkError` if there is an issue contacting the repository or a `ProtocolError` if received in
    # response.
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#GetRecord
    def get(identifier, arguments = {})
      query = {
        'identifier' => identifier,
        'metadataPrefix' => arguments.fetch(:metadata_prefix, 'oai_dc')
      }

      paginator.items('GetRecord', GetRecordParser, query).first
    end

    private

    def paginator
      @paginator ||= Paginator.new(uri, logger_or_options)
    end
  end
end
