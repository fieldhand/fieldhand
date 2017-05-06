require 'fieldhand/header'
require 'ox'

module Fieldhand
  RSpec.describe Header do
    describe '#deleted?' do
      it 'is true when the status is deleted' do
        element = Ox.parse('<header status="deleted"/>')
        header = described_class.new(element)

        expect(header).to be_deleted
      end

      it 'is false when there is no status' do
        element = Ox.parse('<header/>')
        header = described_class.new(element)

        expect(header).not_to be_deleted
      end
    end
  end
end
