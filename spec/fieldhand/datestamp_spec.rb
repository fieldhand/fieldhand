require 'fieldhand/datestamp'

module Fieldhand
  RSpec.describe Datestamp do
    describe '.parse' do
      it 'parses date-granularity datestamps into Dates' do
        expect(described_class.parse('2001-01-01')).
          to eq(::Date.new(2001, 1, 1))
      end

      it 'parses time-granularity datestamps into Times' do
        expect(described_class.parse('2001-01-01T00:00:00Z')).
          to eq(::Time.utc(2001, 1, 1, 0, 0, 0))
      end
    end

    describe '.unparse' do
      it 'unparses Dates into date-granularity datestamps' do
        expect(described_class.unparse(::Date.new(2001, 1, 1))).
          to eq('2001-01-01')
      end

      it 'unparses Times into time-granularity datestamps' do
        expect(described_class.unparse(::Time.utc(2001, 1, 1, 0, 0, 0))).
          to eq('2001-01-01T00:00:00Z')
      end

      it 'unparses non UTC Times into time-granularity datestamps' do
        expect(described_class.unparse(::Time.parse('2001-01-01 01:00:00 +0100'))).
          to eq('2001-01-01T00:00:00Z')
      end

      it 'unparses strings into themselves' do
        expect(described_class.unparse('2001-01-01')).to eq('2001-01-01')
      end
    end
  end
end
