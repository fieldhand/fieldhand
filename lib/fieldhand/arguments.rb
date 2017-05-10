require 'fieldhand/datestamp'

module Fieldhand
  # A class for converting Fieldhand arguments into OAI-PMH query parameters.
  #
  # Specifically:
  #
  # * :metadata_prefix
  # * :resumption_token
  # * :from
  # * :until
  # * :set
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#HTTPRequestFormat
  class Arguments
    VALID_KEYS = {
      :metadata_prefix => 'metadataPrefix',
      :resumption_token => 'resumptionToken',
      :from => 'from',
      :until => 'until',
      :set => 'set'
    }.freeze

    attr_reader :options

    # Return a new `Arguments` with the given `Hash`.
    def initialize(options = {})
      @options = options
    end

    # Return a query as a `Hash` suitable for encoding as a query string in an OAI-PMH request.
    #
    # Converts arguments passed with symbol keys into the corresponding strings as defined in the OAI-PMH protocol,
    # converting values into the appropriate format (e.g. `Time`s, `Date`s, `MetadataFormat`s and `Set`s into strings).
    #
    # Defaults to returning a metadata prefix of "oai_dc".
    #
    # Raises an `ArgumentError` if an unknown argument is encountered.
    #
    # # Examples
    #
    # ```
    # Fieldhand::Arguments.new(:metadata_prefix => 'xoai', :from => Date.new(2001, 1, 1)).to_query
    # #=> { "metadataPrefix" => "xoai", "from" => "2001-01-01" }
    #
    # Fieldhand::Arguments.new(:until => Time.utc(2001, 1, 1, 12, 0, 0)).to_query
    # #=> { "metadataPrefix"=>"oai_dc", "until" => "2001-01-01T12:00:00Z" }
    #
    # Fieldhand::Arguments.new(:foo => "bar").to_query
    # # ArgumentError: unknown argument: foo
    # ```
    def to_query
      options.inject(defaults) do |query, (key, value)|
        raise ::ArgumentError, "unknown argument: #{key}" unless VALID_KEYS.key?(key)

        query[VALID_KEYS.fetch(key)] = convert_value(key, value)

        query
      end
    end

    private

    def defaults
      { 'metadataPrefix' => 'oai_dc' }
    end

    def convert_value(key, value)
      return value.to_s unless key == :from || key == :until

      Datestamp.unparse(value)
    end
  end
end
