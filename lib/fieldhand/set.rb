# frozen_string_literal: true

require 'ox'

module Fieldhand
  # A set is an optional construct for grouping items for the purpose of selective harvesting.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Set
  class Set
    attr_reader :element, :response_date

    # Return a Set with the given element and optional response date.
    #
    # Defaults the response date to the current time.
    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
    end

    # Return the set's spec as its string representation.
    #
    # This means that Sets can be used as arguments that expect a set spec.
    def to_s
      spec
    end

    # Return the set's unique identifier within the repository.
    def spec
      @spec ||= element.setSpec.text
    end

    # Return the set's short human-readable name.
    def name
      @name ||= element.setName.text
    end

    # Return any descriptions of the set as an array of strings.
    #
    # As descriptions can be in any format, Fieldhand does not attempt to parse them but leave this to the user.
    def descriptions
      @descriptions ||= element.locate('setDescription').map { |description| Ox.dump(description) }
    end
  end
end
