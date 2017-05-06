module Fieldhand
  # A metadata format supported by the repository.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats
  class MetadataFormat
    attr_reader :element

    def initialize(element)
      @element = element
    end

    def prefix
      @prefix ||= element.metadataPrefix.text
    end

    def schema
      @schema ||= element.schema.text
    end

    def namespace
      @namespace ||= element.metadataNamespace.text
    end
  end
end
