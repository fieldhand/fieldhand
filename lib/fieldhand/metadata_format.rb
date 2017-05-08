module Fieldhand
  # A metadata format supported by the repository.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListMetadataFormats
  class MetadataFormat
    attr_accessor :response_date, :prefix, :schema, :namespace

    def initialize(response_date = Time.now)
      @response_date = response_date
    end

    def to_s
      prefix
    end
  end
end
