# frozen_string_literal: true

require 'uri'

module Fieldhand
  # A metadata format supported by the repository.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats
  class MetadataFormat
    attr_reader :element, :response_date

    # Return a new Metadata Format for the given element with an optional response date.
    #
    # The response date defaults to the current time.
    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
    end

    # Return the prefix as a string representation of the format.
    #
    # This makes it possible to pass a Metadata Format to methods that expect a string metadata prefix.
    def to_s
      prefix
    end

    # Return the string metadata prefix for the format.
    def prefix
      @prefix ||= element.metadataPrefix.text
    end

    # Return the location of an XML Schema describing the format as a URI.
    def schema
      @schema ||= URI(element.schema.text)
    end

    # Return the XML Namespace URI for the format.
    def namespace
      @namespace ||= URI(element.metadataNamespace.text)
    end
  end
end
