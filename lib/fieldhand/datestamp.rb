require 'date'
require 'time'

module Fieldhand
  # A class to handle datestamps of varying granularity.
  class Datestamp
    def self.parse(datestamp)
      if datestamp.size == 10
        ::Date.xmlschema(datestamp)
      else
        ::Time.xmlschema(datestamp)
      end
    end

    def self.unparse(datestamp)
      return datestamp if datestamp.is_a?(::String)

      datestamp.xmlschema
    end
  end
end
