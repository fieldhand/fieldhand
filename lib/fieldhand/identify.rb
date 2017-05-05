require 'time'

module Fieldhand
  Identify = Struct.new(:name, :base_url, :protocol_version, :earliest_datestamp, :deleted_record, :granularity, :admin_emails, :compression_encodings, :descriptions) do
    def self.from(element)
      name = element.repositoryName.text
      base_url = element.baseURL.text
      protocol_version = element.protocolVersion.text
      earliest_datestamp = Time.xmlschema(element.earliestDatestamp.text)
      deleted_record = element.deletedRecord.text
      granularity = element.granularity.text
      admin_emails = element.locate('adminEmail').map(&:text)
      compression_encodings = element.locate('compression').map(&:text)
      descriptions = element.locate('description')

      new(name, base_url, protocol_version, earliest_datestamp, deleted_record, granularity, admin_emails, compression_encodings, descriptions)
    end
  end
end
