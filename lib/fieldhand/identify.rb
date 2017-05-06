require 'time'

module Fieldhand
  # Information about a repository.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify
  class Identify
    attr_reader :element

    def initialize(element)
      @element = element
    end

    def name
      @name ||= element.repositoryName.text
    end

    def base_url
      @base_url ||= element.baseURL.text
    end

    def protocol_version
      @protocol_version ||= element.protocolVersion.text
    end

    def earliest_datestamp
      @earliest_datestamp ||= Time.xmlschema(element.earliestDatestamp.text)
    end

    def deleted_record
      @deleted_record ||= element.deletedRecord.text
    end

    def granularity
      @granularity ||= element.granularity.text
    end

    def admin_emails
      @admin_emails ||= element.locate('adminEmail/^String')
    end

    def compression_encodings
      @compression_encodings ||= element.locate('compression/^String')
    end

    def descriptions
      @descriptions ||= element.locate('description')
    end
  end
end
