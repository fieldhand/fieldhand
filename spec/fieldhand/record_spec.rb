# encoding: utf-8

require 'fieldhand/record'
require 'ox'

module Fieldhand
  RSpec.describe Record do
    describe '#deleted?' do
      it 'is true when the record has a deleted status' do
        element = ::Ox.parse('<record><header status="deleted"/></record>')
        record = described_class.new(element)

        expect(record).to be_deleted
      end

      it 'is false when the record does not have a status' do
        element = ::Ox.parse('<record><header/></record>')
        record = described_class.new(element)

        expect(record).not_to be_deleted
      end
    end

    describe '#metadata' do
      it 'returns nil if there is no metadata' do
        element = ::Ox.parse('<record/>')
        record = described_class.new(element)

        expect(record.metadata).to be_nil
      end

      it 'returns the metadata as a string' do
        element = ::Ox.parse('<record><metadata>Foo</metadata></record>')
        record = described_class.new(element)

        expect(record.metadata).to eq("\n<metadata>Foo</metadata>\n")
      end
    end

    describe '#to_xml' do
      it 'returns the whole element even if there is no metadata as a string' do
        element = ::Ox.parse('<record/>')
        record = described_class.new(element)

        expect(record.to_xml).to eq("\n<record/>\n")
      end

      it 'returns the whole element as a string' do
        element = ::Ox.parse("<record><metadata>Foo</metadata></record>")
        record = described_class.new(element)

        expect(record.to_xml).to eq(<<-XML)

<record>
  <metadata>Foo</metadata>
</record>
        XML
      end

      it 'returns the whole element with unicode characters as a string' do
        element = ::Ox.parse("<record><metadata>ψFooϨ</metadata></record>")
        record = described_class.new(element)

        expect(record.to_xml).to eq(<<-XML)

<record>
  <metadata>ψFooϨ</metadata>
</record>
        XML
      end
    end

    describe '#about' do
      it 'returns an empty array if there are no about elements' do
        element = ::Ox.parse('<record/>')
        record = described_class.new(element)

        expect(record.about).to be_empty
      end

      it 'returns about sections when present' do
        element = ::Ox.parse('<record><about/><about/></record>')
        record = described_class.new(element)

        expect(record.about.size).to eq(2)
      end

      it 'returns about sections as strings' do
        element = ::Ox.parse('<record><about>Foo</about><about>Bar</about></record>')
        record = described_class.new(element)

        expect(record.about).to contain_exactly("\n<about>Foo</about>\n", "\n<about>Bar</about>\n")
      end
    end

    describe '#response_date' do
      it 'returns the passed response date' do
        element = ::Ox.parse('<record/>')
        record = described_class.new(element, ::Time.utc(2001, 1, 1, 0, 0, 0))

        expect(record.response_date).to eq(::Time.utc(2001, 1, 1, 0, 0, 0))
      end
    end
  end
end
