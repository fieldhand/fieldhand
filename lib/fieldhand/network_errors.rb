# frozen_string_literal: true

module Fieldhand
  NetworkError = ::Class.new(::StandardError)

  # Custom exception to handle unexpected HTTP responses
  class ResponseError < NetworkError
    attr_reader :response

    def initialize(response)
      super("Invalid response: #{response.code} #{response.msg}")

      @response = response
    end
  end
end
