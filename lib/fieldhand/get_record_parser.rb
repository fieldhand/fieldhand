# frozen_string_literal: true

require 'fieldhand/record'

module Fieldhand
  # A parser for GetRecord responses
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#GetRecord
  class GetRecordParser
    attr_reader :response_parser

    # Return a new parser populated with the given response parser.
    def initialize(response_parser)
      @response_parser = response_parser
    end

    # Return an array of `Record`s found in the response.
    def items
      response_parser.
        root.
        locate('GetRecord/record').
        map { |item| Record.new(item, response_parser.response_date) }
    end
  end
end
