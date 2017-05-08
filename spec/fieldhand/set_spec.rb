require 'fieldhand/set'
require 'ox'

module Fieldhand
  RSpec.describe Set do
    describe '#to_s' do
      it 'returns the set spec' do
        set = described_class.new
        set.spec = 'A'

        expect(set.to_s).to eq('A')
      end
    end
  end
end
