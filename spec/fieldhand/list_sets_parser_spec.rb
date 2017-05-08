require 'fieldhand/list_sets_parser'

module Fieldhand
  RSpec.describe ListSetsParser do
    it 'parses out Sets' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_sets_1.xml'))

      expect(parser.items.size).to eq(1)
    end

    it 'populates Sets with the response date' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_sets_1.xml'))
      set = parser.items.first

      expect(set).to have_attributes(:response_date => ::Time.utc(2017, 5, 5, 14, 28, 4))
    end

    it 'populates Sets with their spec' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_sets_1.xml'))
      set = parser.items.first

      expect(set).to have_attributes(:spec => 'A')
    end

    it 'populates Sets with their name' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_sets_1.xml'))
      set = parser.items.first

      expect(set).to have_attributes(:name => 'Set A.')
    end

    it 'parses out resumption tokens' do
      parser = described_class.new
      ::Ox.sax_parse(parser, fixture('list_sets_1.xml'))

      expect(parser.resumption_token).to eq('foobar')
    end

    it 'parses multiple sets in one response' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <ListSets>
            <set/>
            <set/>
            <set/>
          </ListSets>
        </OAI-PMH>
      XML

      expect(parser.items.size).to eq(3)
    end

    it 'returns set descriptions as a raw string' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <ListSets>
            <set>
              <setDescription>
                <foo:bar a="b"><bar>baz</bar><baz>quux</baz></foo:bar>
              </setDescription>
            </set>
          </ListSets>
        </OAI-PMH>
      XML
      set = parser.items.first

      expect(set.descriptions).to contain_exactly('<foo:bar a="b"><bar>baz</bar><baz>quux</baz></foo:bar>')
    end

    it 'returns multiple set descriptions as separate strings' do
      parser = described_class.new
      ::Ox.sax_parse(parser, <<-XML)
        <OAI-PMH>
          <ListSets>
            <set>
              <setDescription>foo</setDescription>
              <setDescription>bar</setDescription>
              <setDescription>baz</setDescription>
            </set>
          </ListSets>
        </OAI-PMH>
      XML
      set = parser.items.first

      expect(set.descriptions).to contain_exactly('foo', 'bar', 'baz')
    end
  end
end
