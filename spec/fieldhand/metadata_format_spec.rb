require 'fieldhand/metadata_format'
require 'ox'

module Fieldhand
  RSpec.describe MetadataFormat do
    describe '#to_s' do
      it 'returns the prefix' do
        element = ::Ox.parse('<metadataFormat><metadataPrefix>xoai</metadataPrefix></metadataFormat>')
        format = described_class.new(element)

        expect(format.to_s).to eq('xoai')
      end
    end
  end
end
