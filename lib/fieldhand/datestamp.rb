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
      case datestamp
      when ::String
        datestamp
      when ::Date
        datestamp.strftime
      when ::Time
        datestamp.utc.xmlschema
      else
        datestamp.xmlschema
      end
    end
  end
end
