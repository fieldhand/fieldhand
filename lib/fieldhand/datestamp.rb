# frozen_string_literal: true

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

    # Return a string UTC datestamp given a string, `Date`, `Time` or anything responding to `xmlschema`.
    #
    # The granularity of the resulting datestamp depends on the input type:
    #
    # * Strings are returned untouched (assuming they are already formatted datestamps)
    # * Dates will return a date-level granularity datestamp, e.g. 2001-01-01
    # * Times will return a time-level granularity UTC datestamp, e.g. 2001-01-01T00:00:00Z
    # * DateTimes will return a time-level granularity UTC datestamp, e.g. 2001-01-01T00:00:00Z
    # * Anything else is assumed to respond to `xmlschema`
    def self.unparse(datestamp)
      case datestamp
      when ::String then datestamp
      when ::DateTime then unparse(::Time.xmlschema(datestamp.to_s))
      when ::Date then datestamp.strftime
      when ::Time then datestamp.utc.xmlschema
      else
        datestamp.xmlschema
      end
    end
  end
end
