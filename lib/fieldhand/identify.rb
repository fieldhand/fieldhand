require 'fieldhand/datestamp'
require 'uri'

module Fieldhand
  # Information about a repository.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify
  class Identify
    attr_reader :element, :response_date

    # Return a new Identify with the given element and optional response date.
    #
    # Defaults the response date to the current time.
    def initialize(element, response_date = Time.now)
      @element = element
      @response_date = response_date
    end

    # Return the human readable name for the repository.
    def name
      @name ||= element.repositoryName.text
    end

    # Return the base URL of the repository as a URI.
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#HTTPRequestFormat
    def base_url
      @base_url ||= URI(element.baseURL.text)
    end

    # Return the version of the OAI-PMH protocol supported by the repository as a string.
    def protocol_version
      @protocol_version ||= element.protocolVersion.text
    end

    # Return the guaranteed lower limit of all datestamps recording changes, modifications, or deletions in the
    # repository as a `Date` or `Time` depending on the granularity of the repository.
    def earliest_datestamp
      @earliest_datestamp ||= Datestamp.parse(element.earliestDatestamp.text)
    end

    # Return the manner in which the repository supports the notion of deleted records as a string.
    #
    # Possible values are:
    #
    # * no
    # * transient
    # * persistent
    #
    # See https://www.openarchives.org/OAI/openarchivesprotocol.html#DeletedRecords
    def deleted_record
      @deleted_record ||= element.deletedRecord.text
    end

    # Return the finest harvesting granularity supported by the repository. The legitimate values are YYYY-MM-DD and
    # YYYY-MM-DDThh:mm:ssZ with meanings as defined in ISO 8601.
    #
    # See http://www.w3.org/TR/NOTE-datetime
    def granularity
      @granularity ||= element.granularity.text
    end

    # Return any e-mail addresses of administrators of the repository as an array of strings.
    def admin_emails
      @admin_emails ||= element.locate('adminEmail/^String')
    end

    # Return any compression encodings supported by the repository as an array of strings.
    def compression
      @compression ||= element.locate('compression/^String')
    end

    # Return any raw description elements used by communities to describe their repositories as an array of strings.
    #
    # As these can be in any format, Fieldhand does not attempt to parse the elements but leaves that to users.
    def descriptions
      @descriptions ||= element.locate('description')
    end
  end
end
