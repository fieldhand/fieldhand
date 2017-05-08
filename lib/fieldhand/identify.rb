require 'fieldhand/datestamp'
require 'uri'

module Fieldhand
  # Information about a repository.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify
  class Identify
    attr_accessor :name, :base_url, :protocol_version, :admin_emails, :earliest_datestamp, :deleted_record,
                  :granularity, :compression, :descriptions, :response_date

    def initialize
      @admin_emails = []
      @compression = []
      @descriptions = []
      @response_date = Time.now
    end
  end
end
