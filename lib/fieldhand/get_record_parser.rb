require 'fieldhand/record'
require 'fieldhand/response_parser'

module Fieldhand
  # A parser for GetRecord responses
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#GetRecord
  class GetRecordParser
    attr_reader :response

    # Return a new parser populated with the given response body.
    def initialize(response)
      @response = response
    end

    # Return an `Enumerator` of `Record`s for each record in the response.
    #
    # Raises a `ProtocolError` for any errors found in the response.
    def items
      return enum_for(:items) unless block_given?

      response_parser.errors.each do |error|
        raise error
      end

      response_parser.root.locate('GetRecord/record').each do |item|
        yield Record.new(item, response_parser.response_date)
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
