require 'date'
require 'time'

module Fieldhand
  # A class to handle datestamps of varying granularity.
  class Datestamp
    def self.parse(datestamp)
      if datestamp.size == 10
        ::Date.strptime(datestamp)
      else
        ::Time.xmlschema(datestamp)
      end
    end

    def self.unparse(datestamp)
      return datestamp if datestamp.is_a?(::String)
      return datestamp.xmlschema if datestamp.respond_to?(:xmlschema)

      datestamp.strftime
    end
  end
end
