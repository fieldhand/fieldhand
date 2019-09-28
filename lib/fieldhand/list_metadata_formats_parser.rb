# frozen_string_literal: true

require 'fieldhand/metadata_format'

module Fieldhand
  # A parser for ListMetadataFormats responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats
  class ListMetadataFormatsParser
    attr_reader :response_parser

    # Return a parser for the given response parser.
    def initialize(response_parser)
      @response_parser = response_parser
    end

    # Return an array of `MetadataFormat`s found in the response.
    def items
      response_parser.
        root.
        locate('ListMetadataFormats/metadataFormat').
        map { |item| MetadataFormat.new(item, response_parser.response_date) }
    end
  end
end
