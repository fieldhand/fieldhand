module Fieldhand
  # A set is an optional construct for grouping items for the purpose of selective harvesting.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Set
  class Set
    attr_accessor :response_date, :spec, :name, :descriptions

    def initialize(response_date = Time.now)
      @response_date = response_date
      @descriptions = []
    end

    def to_s
      spec
    end
  end
end
