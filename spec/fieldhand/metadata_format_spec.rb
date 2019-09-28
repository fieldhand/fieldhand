# frozen_string_literal: true

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

    describe '#response_date' do
      it 'returns the passed response date' do
        element = ::Ox.parse('<metadataFormat/>')
        format = described_class.new(element, ::Time.utc(2001, 1, 1, 0, 0, 0))

        expect(format.response_date).to eq(::Time.utc(2001, 1, 1, 0, 0, 0))
      end
    end
  end
end
