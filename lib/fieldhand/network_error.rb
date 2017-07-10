module Fieldhand
  # Custom exception to handle connection errors and invalid requests
  class NetworkError < StandardError
    attr_reader :response

    def initialize(message, response = nil)
      super(message)
      @response = response
    end
  end
end
