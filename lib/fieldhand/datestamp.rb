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
      when ::DateTime
        unparse(::Time.xmlschema(datestamp.to_s))
      when ::Time
        datestamp.utc.xmlschema
      else
        datestamp.strftime
      end
    end
  end
end
