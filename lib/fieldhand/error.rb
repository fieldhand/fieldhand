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

  class Error
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

    def self.convert(code, message)
      return unless ERROR_CODES.key?(code)

      raise ERROR_CODES.fetch(code), message
    end
  end
end
