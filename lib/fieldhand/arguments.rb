require 'time'
require 'date'

module Fieldhand
  # A class for converting Fieldhand arguments into OAI-PMH query parameters
  class Arguments
    VALID_KEYS = {
      :metadata_prefix => 'metadataPrefix',
      :resumption_token => 'resumptionToken',
      :from => 'from',
      :until => 'until',
      :set => 'set'
    }.freeze

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def to_query
      options.each_with_object(defaults) do |(key, value), query|
        next unless VALID_KEYS.key?(key)

        new_key = VALID_KEYS.fetch(key)
        query[new_key] = convert_value(key, value)
      end
    end

    def defaults
      { 'metadataPrefix' => 'oai_dc' }
    end

    private

    def convert_value(key, value)
      return value.to_s unless key == :from || key == :until
      return value if value.is_a?(String)

      value.xmlschema
    end
  end
end
