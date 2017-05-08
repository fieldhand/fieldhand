require 'fieldhand/identify'
require 'ox'

module Fieldhand
  RSpec.describe Identify do
    describe '#base_url' do
      it 'returns the base URL as a URI' do
        element = ::Ox.parse(<<-XML)
          <Identify>
            <baseURL>http://www.example.com/oai</baseURL>
          </Identify>
        XML
        identify = described_class.new(element)

        expect(identify.base_url).to eq(URI('http://www.example.com/oai'))
      end
    end

    describe '#earliest_datestamp' do
      it 'supports time datestamps' do
        element = ::Ox.parse(<<-XML)
          <Identify>
            <earliestDatestamp>1990-02-01T12:00:00Z</earliestDatestamp>
          </Identify>
        XML
        identify = described_class.new(element)

        expect(identify.earliest_datestamp).to eq(::Time.utc(1990, 2, 1, 12, 0, 0))
      end

      it 'supports date datestamps' do
        element = ::Ox.parse(<<-XML)
          <Identify>
            <earliestDatestamp>1990-02-01</earliestDatestamp>
          </Identify>
        XML
        identify = described_class.new(element)

        expect(identify.earliest_datestamp).to eq(::Date.new(1990, 2, 1))
      end
    end

    describe '#response_date' do
      it 'returns the passed response date' do
        element = ::Ox.parse('<Identify/>')
        identify = described_class.new(element, ::Time.utc(2001, 1, 1, 0, 0, 0))

        expect(identify.response_date).to eq(::Time.utc(2001, 1, 1, 0, 0, 0))
      end
    end
  end
end
