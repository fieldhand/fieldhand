require 'time'

module Fieldhand
  Record = Struct.new(:status, :identifier, :datestamp, :sets, :metadata) do
    def self.from(element)
      status = element.header['status']
      identifier = element.header.identifier.text
      datestamp = Time.xmlschema(element.header.datestamp.text)
      sets = element.header.locate('setSpec').map(&:text)
      metadata = element.locate('metadata').first

      new(status, identifier, datestamp, sets, metadata)
    end
  end
end
