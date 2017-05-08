require 'uri'

module Fieldhand
  # A metadata format supported by the repository.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats
  class MetadataFormat
    attr_reader :element, :response_date

    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
    end

    def to_s
      prefix
    end

    def prefix
      @prefix ||= element.metadataPrefix.text
    end

    def schema
      @schema ||= URI(element.schema.text)
    end

    def namespace
      @namespace ||= URI(element.metadataNamespace.text)
    end
  end
end
