require 'fieldhand/list_identifiers_parser'

module Fieldhand
  RSpec.describe ListIdentifiersParser do
    it 'parses out Headers' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_identifiers.xml'))

      expect(parser.items.size).to eq(2)
    end

    it 'populates Headers with their attributes' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_identifiers.xml'))
      header = parser.items.first

      expect(header).to have_attributes(:identifier => 'oai:oai.datacite.org:22',
                                        :datestamp => ::Time.utc(2011, 3, 3, 16, 29, 24),
                                        :sets => %w[BL BL.WAP])
    end

    it 'populates the status of deleted Headers' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_identifiers.xml'))
      header = parser.items.first

      expect(header).to be_deleted
    end

    it 'parses out the resumption token' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <ListIdentifiers>
            <resumptionToken>foobar</resumptionToken>
          </ListIdentifiers>
        </OAI-PMH>
      XML

      expect(parser.resumption_token).to eq('foobar')
    end
  end
end
