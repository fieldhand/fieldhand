# frozen_string_literal: true

require 'fieldhand/identify'

module Fieldhand
  # A parser for Identify responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify
  class IdentifyParser
    attr_reader :response_parser

    # Return a new parser for the given response parser.
    def initialize(response_parser)
      @response_parser = response_parser
    end

    # Return an array of `Identify`s found in the response.
    #
    # In reality, there will only ever be at most one `Identify` in a response but having a consistent interface with
    # the other parsers keeps the supporting code simpler.
    def items
      response_parser.
        root.
        locate('Identify').
        map { |item| Identify.new(item, response_parser.response_date) }
    end
  end
end
