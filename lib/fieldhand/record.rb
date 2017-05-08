require 'fieldhand/header'
require 'ox'

module Fieldhand
  # A record is metadata expressed in a single format.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Record
  class Record
    attr_reader :element, :response_date

    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
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

    def metadata
      @metadata ||= element.locate('metadata[0]').map { |metadata| Ox.dump(metadata) }.first
    end

    def about
      @about ||= element.locate('about').map { |about| Ox.dump(about) }
    end

    def header
      @header ||= Header.new(element.header)
    end
  end
end
