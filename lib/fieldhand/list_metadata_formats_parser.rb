require 'fieldhand/datestamp'
require 'fieldhand/metadata_format'
require 'ox'
require 'uri'

module Fieldhand
  # A SAX parser for ListMetadataFormats responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats
  class ListMetadataFormatsParser < ::Ox::Sax
    attr_reader :items, :stack
    attr_accessor :item, :response_date, :resumption_token

    def initialize
      @items = []
      @stack = []
      @response_date = Time.now
    end

    def current_element
      stack.last
    end

    def start_element(name)
      stack.push(name)

      case name
      when :metadataFormat
        self.item = MetadataFormat.new(response_date)
      end
    end

    def end_element(name)
      stack.pop

      case name
      when :metadataFormat
        items << item
      end
    end

    def text(str)
      case current_element
      when :responseDate
        self.response_date = Datestamp.parse(str)
      when :metadataPrefix
        item.prefix = str
      when :schema
        item.schema = URI(str)
      when :metadataNamespace
        item.namespace = URI(str)
      when :resumptionToken
        self.resumption_token = str
      end
    end
  end
end
