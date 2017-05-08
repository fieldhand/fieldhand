require 'fieldhand/metadata_format'

module Fieldhand
  RSpec.describe MetadataFormat do
    describe '#to_s' do
      it 'returns the prefix' do
        format = described_class.new
        format.prefix = 'xoai'

        expect(format.to_s).to eq('xoai')
      end
    end
  end
end
