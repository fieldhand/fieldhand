require 'fieldhand/identify_parser'

module Fieldhand
  RSpec.describe IdentifyParser do
    it 'parses out Identify responses' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('identify.xml'))

      expect(parser.items.size).to eq(1)
    end

    it 'parses out the descriptions as raw strings' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <Identify>
            <description>
              <foo:bar a="1">
                <bar:baz>quux</bar:baz>
              </foo:bar>
              <quux>quuz</quux>
            </description>
          </Identify>
        </OAI-PMH>
      XML
      identify = parser.items.first

      expect(identify.descriptions).
        to contain_exactly('<foo:bar a="1"><bar:baz>quux</bar:baz></foo:bar><quux>quuz</quux>')
    end

    it 'parses out the base URL as a URI' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('identify.xml'))
      identify = parser.items.first

      expect(identify).to have_attributes(:base_url => URI('http://oai.datacite.org/oai'))
    end

    it 'parses time datestamps' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <Identify>
            <earliestDatestamp>1990-02-01T12:00:00Z</earliestDatestamp>
          </Identify>
        </OAI-PMH>
      XML
      identify = parser.items.first

      expect(identify).to have_attributes(:earliest_datestamp => ::Time.utc(1990, 2, 1, 12, 0, 0))
    end

    it 'parses date datestamps' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <Identify>
            <earliestDatestamp>1990-02-01</earliestDatestamp>
          </Identify>
        </OAI-PMH>
      XML
      identify = parser.items.first

      expect(identify).to have_attributes(:earliest_datestamp => ::Date.new(1990, 2, 1))
    end

    it 'parses the response date' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <responseDate>2017-05-05T20:06:23Z</responseDate>
          <Identify/>
        </OAI-PMH>
      XML
      identify = parser.items.first

      expect(identify).to have_attributes(:response_date => ::Time.utc(2017, 5, 5, 20, 6, 23))
    end
  end
end
