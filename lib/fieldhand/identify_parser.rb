require 'fieldhand/identify'
require 'fieldhand/response_parser'

module Fieldhand
  # A parser for Identify responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify
  class IdentifyParser
    attr_reader :response

    # Return a new parser for the given response body.
    def initialize(response)
      @response = response
    end

    # Return an `Enumerator` of `Identify`s for each found in the response.
    #
    # In reality, there will only ever be at most one `Identify` in a response but having a consistent interface with
    # the other parsers keeps the supporting code simpler.
    #
    # Raises a `ProtocolError` for any errors found in the response.
    def items
      return enum_for(:items) unless block_given?

      response_parser.errors.each do |error|
        raise error
      end

      response_parser.root.locate('Identify').each do |item|
        yield Identify.new(item, response_parser.response_date)
      end
    end

    # Return the resumption token from the response, if present.
    def resumption_token
      response_parser.resumption_token
    end

    private

    def response_parser
      @response_parser ||= ResponseParser.new(response)
    end
  end
end
