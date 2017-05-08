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

    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
    end

    def deleted?
      status == 'deleted'
    end

    def status
      element['status']
    end

    def identifier
      @identifier ||= element.identifier.text
    end

    def datestamp
      @datestamp ||= Datestamp.parse(element.datestamp.text)
    end

    def sets
      @sets ||= element.locate('setSpec/^String')
    end
  end
end
