module Fieldhand
  MetadataFormat = Struct.new(:prefix, :schema, :namespace) do
    def self.from(element)
      prefix = element.metadataPrefix.text
      schema = element.schema.text
      namespace = element.metadataNamespace.text

      new(prefix, schema, namespace)
    end
  end
end
