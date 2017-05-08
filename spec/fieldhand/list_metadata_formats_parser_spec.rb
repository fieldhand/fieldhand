require 'fieldhand/list_metadata_formats_parser'

module Fieldhand
  RSpec.describe ListMetadataFormatsParser do
    it 'parses out Metadata Formats' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_metadata_formats.xml'))

      expect(parser.items.size).to eq(1)
    end

    it 'populates Formats with the response date' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_metadata_formats.xml'))
      format = parser.items.first

      expect(format).to have_attributes(:response_date => ::Time.utc(2017, 5, 5, 13, 45, 53))
    end

    it 'populates Formats with their prefix' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_metadata_formats.xml'))
      format = parser.items.first

      expect(format).to have_attributes(:prefix => 'oai_dc')
    end

    it 'populates Formats with their schema as a URI' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_metadata_formats.xml'))
      format = parser.items.first

      expect(format).to have_attributes(:schema => URI('http://www.openarchives.org/OAI/2.0/oai_dc.xsd'))
    end

    it 'populates Formats with their namespace as a URI' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_metadata_formats.xml'))
      format = parser.items.first

      expect(format).to have_attributes(:namespace => URI('http://www.openarchives.org/OAI/2.0/oai_dc/'))
    end

    it 'parses multiple formats in one response' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <ListMetadataFormats>
            <metadataFormat/>
            <metadataFormat/>
            <metadataFormat/>
          </ListMetadataFormats>
        </OAI-PMH>
      XML

      expect(parser.items.size).to eq(3)
    end
  end
end
