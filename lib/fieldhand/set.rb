module Fieldhand
  # A set is an optional construct for grouping items for the purpose of selective harvesting.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Set
  class Set
    attr_reader :element

    def initialize(element)
      @element = element
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
      @descriptions ||= element.locate('setDescription')
    end
  end
end
