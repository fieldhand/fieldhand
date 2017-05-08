require 'fieldhand/record'
require 'ox'

module Fieldhand
  RSpec.describe Record do
    describe '#deleted?' do
      it 'is true when the record has a deleted status' do
        record = described_class.new
        record.header.status = 'deleted'

        expect(record).to be_deleted
      end

      it 'is false when the record does not have a status' do
        record = described_class.new

        expect(record).not_to be_deleted
      end
    end

    describe '#about' do
      it 'returns an empty array if there are no about elements' do
        record = described_class.new

        expect(record.about).to be_empty
      end
    end
  end
end
