require 'fieldhand/paginator'
require 'fieldhand/metadata_format'
require 'fieldhand/set'
require 'fieldhand/record'

module Fieldhand
  class Repository
    attr_reader :uri

    def initialize(uri)
      @uri = uri.is_a?(URI) ? uri : URI(uri)
    end

    def metadata_formats
      return enum_for(:metadata_formats) unless block_given?

      paginator.items('ListMetadataFormats', 'metadataFormat').each do |format|
        yield MetadataFormat.from(format)
      end
    end

    def sets
      return enum_for(:sets) unless block_given?

      paginator.items('ListSets', 'set').each do |set|
        yield Set.from(set)
      end
    end

    def records(metadata_prefix)
      return enum_for(:records, metadata_prefix) unless block_given?

      paginator.items('ListRecords', 'record', 'metadataPrefix' => metadata_prefix).each do |record|
        yield Record.from(record)
      end
    end

    private

    def paginator
      @paginator ||= Paginator.new(uri)
    end
  end
end
