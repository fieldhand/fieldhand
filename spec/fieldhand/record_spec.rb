require 'fieldhand/record'
require 'ox'

module Fieldhand
  RSpec.describe Record do
    describe '#deleted?' do
      it 'is true when the record has a deleted status' do
        element = Ox.parse('<record><header status="deleted"/></record>')
        record = described_class.new(element)

        expect(record).to be_deleted
      end

      it 'is false when the record does not have a status' do
        element = Ox.parse('<record><header/></record>')
        record = described_class.new(element)

        expect(record).not_to be_deleted
      end
    end
  end
end
