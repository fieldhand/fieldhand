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
    attr_accessor :response_date, :status, :identifier, :datestamp, :sets

    def initialize(response_date = Time.now)
      @response_date = response_date
      @sets = []
    end

    def deleted?
      status == 'deleted'
    end
  end
end
