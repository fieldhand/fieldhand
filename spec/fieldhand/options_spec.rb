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

    describe '#retries' do
      it 'defaults to 0' do
        options = described_class.new({})

        expect(options.retries).to eq(0)
      end

      it 'can be overridden by passing an option' do
        options = described_class.new(:retries => 5)

        expect(options.retries).to eq(5)
      end
    end

    describe '#interval' do
      it 'defaults to 10' do
        options = described_class.new({})

        expect(options.interval).to eq(10)
      end

      it 'can be overridden by passing an option' do
        options = described_class.new(:interval => 5)

        expect(options.interval).to eq(5)
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

    describe '#headers' do
      it 'defaults to an empty hash' do
        options = described_class.new({})

        expect(options.headers).to be_empty
      end

      it 'can be overridden by passing headers in an option' do
        options = described_class.new(:headers => { 'Crossref-Plus-API-Token' => 'decafbad' })

        expect(options.headers).to eq({ 'Crossref-Plus-API-Token' => 'decafbad' })
      end

      it 'overrides authorization headers with a bearer_token' do
        options = described_class.new(:headers => { 'Authorization' => 'Bearer aaabbbccc' }, :bearer_token => 'decafbad')

        expect(options.headers).to eq({ 'Authorization' => 'Bearer decafbad' })
      end
    end
  end
end
