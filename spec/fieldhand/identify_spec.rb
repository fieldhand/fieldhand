require 'fieldhand/identify'
require 'ox'

module Fieldhand
  RSpec.describe Identify do
    describe '#base_url' do
      it 'returns the base URL as a URI' do
        element = Ox.parse(<<-XML)
          <Identify>
            <baseURL>http://www.example.com/oai</baseURL>
          </Identify>
        XML
        identify = described_class.new(element)

        expect(identify.base_url).to eq(URI('http://www.example.com/oai'))
      end
    end
  end
end
