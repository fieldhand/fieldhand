require 'fieldhand/header'
require 'ox'

module Fieldhand
  # A record is metadata expressed in a single format.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Record
  class Record
    attr_reader :element, :response_date

    # Return a new Record for the given element with an optional response date.
    #
    # Defaults the response date to the current time.
    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
    end

    # Test whether this item is marked as deleted or not according to its header.
    #
    # Note that a repository's support for deleted records can be interrogated through the `Identify` request, see
    # https://www.openarchives.org/OAI/openarchivesprotocol.html#DeletedRecords
    def deleted?
      header.deleted?
    end

    # Return the optional status of this item according to its header.
    def status
      header.status
    end

    # Return the unique identifier of this item according to its header.
    def identifier
      header.identifier
    end

    # Return the UTC datestamp of this item according to its header as a `Date` or `Time` depending on the granularity
    # of this repository.
    def datestamp
      header.datestamp
    end

    # Return any set memberships of this item according to its header.
    def sets
      header.sets
    end

    # Return this whole item as a string
    def to_xml
      Ox.dump(element, :encoding => 'utf-8')
    end

    # Return the single manifestation of the metadata of this item as a string, if present.
    #
    # As metadata can be in any format, Fieldhand does not attempt to parse it but leave that to the user.
    def metadata
      @metadata ||= element.locate('metadata[0]').map { |metadata| Ox.dump(metadata) }.first
    end

    # Return any about elements describing the metadata of this record as an array of strings.
    #
    # As about elements can be in any format, Fieldhand does not attempt to parse them but leave that to the user.
    def about
      @about ||= element.locate('about').map { |about| Ox.dump(about) }
    end

    # Return the associated Header for this record.
    def header
      @header ||= Header.new(element.header)
    end
  end
end
