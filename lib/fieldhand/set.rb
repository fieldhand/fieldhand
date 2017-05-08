require 'ox'

module Fieldhand
  # A set is an optional construct for grouping items for the purpose of selective harvesting.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Set
  class Set
    attr_reader :element, :response_date

    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
    end

    def to_s
      spec
    end

    def spec
      @spec ||= element.setSpec.text
    end

    def name
      @name ||= element.setName.text
    end

    def descriptions
      @descriptions ||= element.locate('setDescription').map { |description| Ox.dump(description) }
    end
  end
end
