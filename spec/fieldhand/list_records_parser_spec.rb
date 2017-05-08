require 'fieldhand/list_records_parser'

module Fieldhand
  RSpec.describe ListRecordsParser do
    it 'parses out Records' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_records_1.xml'))

      expect(parser.items.size).to eq(2)
    end

    it 'populates Records with the response date' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_records_1.xml'))
      record = parser.items.first

      expect(record).to have_attributes(:response_date => ::Time.utc(2017, 5, 5, 14, 48, 37))
    end

    it 'populates Records with their identifier' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_records_1.xml'))
      record = parser.items.first

      expect(record).to have_attributes(:identifier => 'oai:oai.datacite.org:32355')
    end

    it 'populates Records with their datestamp' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_records_1.xml'))
      record = parser.items.first

      expect(record).to have_attributes(:datestamp => ::Time.utc(2011, 7, 7, 11, 19, 3))
    end

    it 'populates Records with their sets' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_records_1.xml'))
      record = parser.items.first

      expect(record.sets).to contain_exactly('TIB', 'TIB.DAGST')
    end

    it 'populates Records with their full header' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_records_1.xml'))
      record = parser.items.first

      expect(record.header).to have_attributes(:identifier => 'oai:oai.datacite.org:32355',
                                               :datestamp => ::Time.utc(2011, 7, 7, 11, 19, 3),
                                               :sets => ['TIB', 'TIB.DAGST'])
    end

    it 'populates deleted records with their status' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_records_2.xml'))
      record = parser.items.first

      expect(record).to be_deleted
    end

    it 'parses out resumption tokens' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_records_1.xml'))

      expect(parser.resumption_token).to eq('foobar')
    end

    it 'returns record metadata as a raw string' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <ListRecords>
            <record>
              <metadata>
                <foo:bar a="b"><bar>baz</bar><baz>quux</baz></foo:bar>
              </metadata>
            </record>
          </ListRecords>
        </OAI-PMH>
      XML
      record = parser.items.first

      expect(record.metadata).to eq('<foo:bar a="b"><bar>baz</bar><baz>quux</baz></foo:bar>')
    end

    it 'returns record about sections as raw strings' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <ListRecords>
            <record>
              <about>foo</about>
              <about>bar</about>
              <about>baz</about>
            </record>
          </ListRecords>
        </OAI-PMH>
      XML
      record = parser.items.first

      expect(record.about).to contain_exactly('foo', 'bar', 'baz')
    end
  end
end
