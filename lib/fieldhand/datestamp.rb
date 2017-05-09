require 'date'
require 'time'

module Fieldhand
  # A class to handle datestamps of varying granularity.
  class Datestamp
    # Return either a `Date` or `Time` for the given string datestamp.
    #
    # As repositories may only support date-level granularity rather than time-level granularity, we need to handle both
    # types of datestamp.
    def self.parse(datestamp)
      if datestamp.size == 10
        ::Date.strptime(datestamp)
      else
        ::Time.xmlschema(datestamp)
      end
    end

    # Return a string UTC datestamp given a string, `Date` or `Time`.
    #
    # The granularity of the resulting datestamp depends on the input type:
    #
    # * Strings are returned untouched (assuming they are already formatted datestamps)
    # * Dates will return a date-level granularity datestamp, e.g. 2001-01-01
    # * Times will return a time-level granularity UTC datestamp, e.g. 2001-01-01T00:00:00Z
    # * DateTimes will return a time-level granularity UTC datestamp, e.g. 2001-01-01T00:00:00Z
    # * Anything else is assumed to respond to `to_time`, `utc` or `xmlschema`
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
