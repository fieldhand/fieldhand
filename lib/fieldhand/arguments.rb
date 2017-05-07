require 'fieldhand/datestamp'

module Fieldhand
  # A class for converting Fieldhand arguments into OAI-PMH query parameters.
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
      options.inject(defaults) do |query, (key, value)|
        raise ::ArgumentError, "unknown argument: #{key}" unless VALID_KEYS.key?(key)

        query[VALID_KEYS.fetch(key)] = convert_value(key, value)

        query
      end
    end

    def defaults
      { 'metadataPrefix' => 'oai_dc' }
    end

    private

    def convert_value(key, value)
      return value.to_s unless key == :from || key == :until

      Datestamp.unparse(value)
    end
  end
end
