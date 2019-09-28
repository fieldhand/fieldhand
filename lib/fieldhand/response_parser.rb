# frozen_string_literal: true

require 'fieldhand/datestamp'
require 'ox'

module Fieldhand
  ProtocolError = ::Class.new(::StandardError)
  BadArgumentError = ::Class.new(ProtocolError)
  BadResumptionTokenError = ::Class.new(ProtocolError)
  BadVerbError = ::Class.new(ProtocolError)
  CannotDisseminateFormatError = ::Class.new(ProtocolError)
  IdDoesNotExistError = ::Class.new(ProtocolError)
  NoRecordsMatchError = ::Class.new(ProtocolError)
  NoMetadataFormatsError = ::Class.new(ProtocolError)
  NoSetHierarchyError = ::Class.new(ProtocolError)

  # A parser for elements common to all OAI-PMH HTTP responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#HTTPResponseFormat
  class ResponseParser
    ERROR_CODES = {
      'badArgument' => BadArgumentError,
      'badResumptionToken' => BadResumptionTokenError,
      'badVerb' => BadVerbError,
      'cannotDisseminateFormat' => CannotDisseminateFormatError,
      'idDoesNotExist' => IdDoesNotExistError,
      'noRecordsMatch' => NoRecordsMatchError,
      'noMetadataFormats' => NoMetadataFormatsError,
      'noSetHierarchy' => NoSetHierarchyError
    }.freeze

    attr_reader :response

    # Return a new parser for the given response body.
    def initialize(response)
      @response = response
    end

    # Return the response date as a `Date` or `Time` depending on the granularity of the repository.
    def response_date
      @response_date ||= root.locate('responseDate[0]/^String').map { |date| Datestamp.parse(date) }.first
    end

    # Return any errors found in the response as `ProtocolError`s.
    #
    # Note that this does not _raise_ the errors but simply returns them.
    def errors
      @errors ||= root.locate('error').map { |error| convert_error(error) }
    end

    # Return the resumption token from the response, if present.
    def resumption_token
      @resumption_token ||= root.locate('?/resumptionToken[0]/^String').first
    end

    # Return the root element of the parsed document.
    def root
      @root ||= ::Ox.load(response, :strip_namespace => 'oai').root
    end

    private

    def convert_error(element)
      return unless ERROR_CODES.key?(element['code'])

      ERROR_CODES.fetch(element['code']).new(element.text)
    end
  end
end
