require 'fieldhand/header'
require 'ox'

module Fieldhand
  RSpec.describe Header do
    describe '#deleted?' do
      it 'is true when the status is deleted' do
        element = ::Ox.parse('<header status="deleted"/>')
        header = described_class.new(element)

        expect(header).to be_deleted
      end

      it 'is false when there is no status' do
        element = ::Ox.parse('<header/>')
        header = described_class.new(element)

        expect(header).not_to be_deleted
      end
    end

    describe '#datestamp' do
      it 'supports time-granularity datestamps' do
        element = ::Ox.parse('<header><datestamp>2001-01-01T00:00:00Z</datestamp></header>')
        header = described_class.new(element)

        expect(header.datestamp).to eq(::Time.utc(2001, 1, 1, 0, 0, 0))
      end

      it 'supports date-granularity datestamps' do
        element = ::Ox.parse('<header><datestamp>2001-01-01</datestamp></header>')
        header = described_class.new(element)

        expect(header.datestamp).to eq(::Date.new(2001, 1, 1))
      end
    end

    describe '#response_date' do
      it 'returns the passed response date' do
        element = ::Ox.parse('<header/>')
        header = described_class.new(element, ::Time.utc(2001, 1, 1, 0, 0, 0))

        expect(header.response_date).to eq(::Time.utc(2001, 1, 1, 0, 0, 0))
      end
    end
  end
end
