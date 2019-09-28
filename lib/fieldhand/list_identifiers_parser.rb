# frozen_string_literal: true

require 'fieldhand/header'

module Fieldhand
  # A parser for ListIdentifiers responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListIdentifiers
  class ListIdentifiersParser
    attr_reader :response_parser

    # Return a new parser for the given response parser.
    def initialize(response_parser)
      @response_parser = response_parser
    end

    # Return an array of `Header`s found in the response.
    def items
      response_parser.
        root.
        locate('ListIdentifiers/header').
        map { |item| Header.new(item, response_parser.response_date) }
    end
  end
end
