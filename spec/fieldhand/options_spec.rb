require 'fieldhand/options'

module Fieldhand
  RSpec.describe Options do
    describe '#timeout' do
      it 'defaults to 60 seconds' do
        options = described_class.new({})

        expect(options.timeout).to eq(60)
      end

      it 'can be overridden by passing an option' do
        options = described_class.new(:timeout => 10)

        expect(options.timeout).to eq(10)
      end

      it 'can be set to nil' do
        options = described_class.new(:timeout => nil)

        expect(options.timeout).to be_nil
      end
    end

    describe '#logger' do
      it 'defaults to a null logger' do
        options = described_class.new({})

        expect(options.logger).to be_a(::Logger)
      end

      it 'can be overridden by passing a logger directly' do
        logger = ::Logger.new(STDOUT)
        options = described_class.new(logger)

        expect(options.logger).to eq(logger)
      end

      it 'can be overridden by passing a logger in an option' do
        logger = ::Logger.new(STDOUT)
        options = described_class.new(:logger => logger)

        expect(options.logger).to eq(logger)
      end

      it 'can be set to nil directly' do
        options = described_class.new(nil)

        expect(options.logger).to be_nil
      end

      it 'can be set to nil through an option' do
        options = described_class.new(:logger => nil)

        expect(options.logger).to be_nil
      end
    end

    describe '#bearer_token' do
      it 'defaults to nil' do
        options = described_class.new({})

        expect(options.bearer_token).to be_nil
      end

      it 'can be overridden by passing a token in an option' do
        options = described_class.new(:bearer_token => 'decafbad')

        expect(options.bearer_token).to eq('decafbad')
      end
    end
  end
end
