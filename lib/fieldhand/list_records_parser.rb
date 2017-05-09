require 'fieldhand/record'

module Fieldhand
  # A parser for ListRecords responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListRecords
  class ListRecordsParser
    attr_reader :response_parser

    # Return a parser for the given response body.
    def initialize(response_parser)
      @response_parser = response_parser
    end

    # Return an array of `Record`s found in the response.
    def items
      response_parser.
        root.
        locate('ListRecords/record').
        map { |item| Record.new(item, response_parser.response_date) }
    end
  end
end
