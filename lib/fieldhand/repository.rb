require 'fieldhand/arguments'
require 'fieldhand/header'
require 'fieldhand/identify'
require 'fieldhand/logger'
require 'fieldhand/metadata_format'
require 'fieldhand/paginator'
require 'fieldhand/record'
require 'fieldhand/set'
require 'uri'

module Fieldhand
  # A repository is a network accessible server that can process the 6 OAI-PMH requests.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html
  class Repository
    attr_reader :uri, :logger

    def initialize(uri, logger = Logger.null)
      @uri = uri.is_a?(::URI) ? uri : URI(uri)
      @logger = logger
    end

    def identify
      paginator.
        items('Identify', 'Identify').
        map { |identify| Identify.new(identify) }.
        first
    end

    def metadata_formats(identifier = nil)
      return enum_for(:metadata_formats, identifier) unless block_given?

      arguments = {}
      arguments['identifier'] = identifier if identifier

      paginator.
        items('ListMetadataFormats', 'ListMetadataFormats/metadataFormat', arguments).
        each do |format|
          yield MetadataFormat.new(format)
        end
    end

    def sets
      return enum_for(:sets) unless block_given?

      paginator.
        items('ListSets', 'ListSets/set').
        each do |set|
          yield Set.new(set)
        end
    end

    def records(arguments = {})
      return enum_for(:records, arguments) unless block_given?

      query = Arguments.new(arguments).to_query

      paginator.
        items('ListRecords', 'ListRecords/record', query).
        each do |record|
          yield Record.new(record)
        end
    end

    def identifiers(arguments = {})
      return enum_for(:identifiers, arguments) unless block_given?

      query = Arguments.new(arguments).to_query

      paginator.
        items('ListIdentifiers', 'ListIdentifiers/header', query).
        each do |header|
          yield Header.new(header)
        end
    end

    def get(identifier, arguments = {})
      query = {
        'identifier' => identifier,
        'metadataPrefix' => arguments.fetch(:metadata_prefix, 'oai_dc')
      }

      paginator.
        items('GetRecord', 'GetRecord/record', query).
        map { |record| Record.new(record) }.
        first
    end

    private

    def paginator
      @paginator ||= Paginator.new(uri, logger)
    end
  end
end
