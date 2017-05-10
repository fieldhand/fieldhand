require 'fieldhand/set'

module Fieldhand
  # A parser for ListSets responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListSets
  class ListSetsParser
    attr_reader :response_parser

    # Return a new parser for the given response parser.
    def initialize(response_parser)
      @response_parser = response_parser
    end

    # Return an array of `Set`s found in the response.
    def items
      response_parser.
        root.
        locate('ListSets/set').
        map { |item| Set.new(item, response_parser.response_date) }
    end
  end
end
