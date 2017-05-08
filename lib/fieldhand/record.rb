require 'fieldhand/header'

module Fieldhand
  # A record is metadata expressed in a single format.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Record
  class Record
    attr_accessor :response_date, :header, :metadata, :about

    def initialize(response_date = Time.now)
      @response_date = response_date
      @header = Header.new(response_date)
      @about = []
    end

    def deleted?
      header.deleted?
    end

    def status
      header.status
    end

    def identifier
      header.identifier
    end

    def datestamp
      header.datestamp
    end

    def sets
      header.sets
    end
  end
end
