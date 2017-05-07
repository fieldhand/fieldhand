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
    end
  end
end
