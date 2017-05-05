require 'fieldhand/paginator'
require 'fieldhand/metadata_format'
require 'fieldhand/set'
require 'fieldhand/record'
require 'fieldhand/identify'
require 'fieldhand/header'

module Fieldhand
  class Repository
    attr_reader :uri

    def initialize(uri)
      @uri = uri.is_a?(URI) ? uri : URI(uri)
    end

    def identify
      paginator.items('Identify', 'Identify').map { |identify|
        Identify.from(identify)
      }.first
    end

    def metadata_formats
      return enum_for(:metadata_formats) unless block_given?

      paginator.items('ListMetadataFormats', 'ListMetadataFormats/metadataFormat').each do |format|
        yield MetadataFormat.from(format)
      end
    end

    def sets
      return enum_for(:sets) unless block_given?

      paginator.items('ListSets', 'ListSets/set').each do |set|
        yield Set.from(set)
      end
    end

    def records(metadata_prefix, query = {})
      return enum_for(:records, metadata_prefix, query) unless block_given?

      paginator.items('ListRecords', 'ListRecords/record', query.merge('metadataPrefix' => metadata_prefix)).each do |record|
        yield Record.from(record)
      end
    end

    def identifiers(metadata_prefix, query = {})
      return enum_for(:identifiers, metadata_prefix, query) unless block_given?

      paginator.items('ListIdentifiers', 'ListIdentifiers/header', query.merge('metadataPrefix' => metadata_prefix)).each do |header|
        yield Header.from(header)
      end
    end

    def record(identifier, metadata_prefix)
      paginator.items('GetRecord', 'GetRecord/record', 'metadataPrefix' => metadata_prefix, 'identifier' => identifier).map { |record|
        Record.from(record)
      }.first
    end

    private

    def paginator
      @paginator ||= Paginator.new(uri)
    end
  end
end
