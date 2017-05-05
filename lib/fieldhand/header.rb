module Fieldhand
  Header = Struct.new(:status, :identifier, :datestamp, :sets) do
    def self.from(element)
      status = element['status']
      identifier = element.identifier.text
      datestamp = Time.xmlschema(element.datestamp.text)
      sets = element.locate('setSpec').map(&:text)

      new(status, identifier, datestamp, sets)
    end
  end
end
