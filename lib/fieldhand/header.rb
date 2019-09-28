# frozen_string_literal: true

require 'fieldhand/datestamp'

module Fieldhand
  # Contains the unique identifier of the item and properties necessary for selective harvesting. The header consists of
  # the following parts:
  #
  # * the unique identifier -- the unique identifier of an item in a repository;
  # * the datestamp -- the date of creation, modification or deletion of the record for the purpose of selective
  #   harvesting.
  # * zero or more setSpec elements -- the set membership of the item for the purpose of selective harvesting.
  # * an optional status attribute with a value of deleted indicates the withdrawal of availability of the specified
  #   metadata format for the item, dependent on the repository support for deletions.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#header
  class Header
    attr_reader :element, :response_date

    # Return a new Header with the given element and an optional response date.
    #
    # Defaults the response date to the current time.
    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
    end

    # Test whether this item is marked as deleted or not.
    #
    # Note that a repository's support for deleted records can be interrogated through the `Identify` request, see
    # https://www.openarchives.org/OAI/openarchivesprotocol.html#DeletedRecords
    def deleted?
      status == 'deleted'
    end

    # Return the optional status of this item.
    def status
      element['status']
    end

    # Return the unique identifier of this item.
    def identifier
      @identifier ||= element.identifier.text
    end

    # Return the UTC datestamp of this item.
    def datestamp
      @datestamp ||= Datestamp.parse(element.datestamp.text)
    end

    # Return any set memberships of this item.
    def sets
      @sets ||= element.locate('setSpec/^String')
    end
  end
end
