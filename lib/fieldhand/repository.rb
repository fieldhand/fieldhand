require 'fieldhand/paginator'
require 'fieldhand/metadata_format'
require 'fieldhand/set'
require 'fieldhand/record'

module Fieldhand
  class Repository
    attr_reader :uri

    def initialize(uri)
      @uri = URI(uri)
    end

    def metadata_formats
      Enumerator.new do |yielder|
        paginator.items('ListMetadataFormats', 'metadataFormat').each do |format|
          yielder << MetadataFormat.from(format)
        end
      end
    end

    def sets
      Enumerator.new do |yielder|
        paginator.items('ListSets', 'set').each do |set|
          yielder << Set.from(set)
        end
      end
    end

    def records(metadata_prefix)
      Enumerator.new do |yielder|
        paginator.items('ListRecords', 'record', 'metadataPrefix' => metadata_prefix).each do |record|
          yielder << Record.from(record)
        end
      end
    end

    private

    def paginator
      @paginator ||= Paginator.new(uri)
    end
  end
end
