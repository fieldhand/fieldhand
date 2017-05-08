require 'fieldhand/header'
require 'ox'

module Fieldhand
  RSpec.describe Header do
    describe '#deleted?' do
      it 'is true when the status is deleted' do
        header = described_class.new
        header.status = 'deleted'

        expect(header).to be_deleted
      end

      it 'is false when there is no status' do
        header = described_class.new

        expect(header).not_to be_deleted
      end
    end
  end
end
