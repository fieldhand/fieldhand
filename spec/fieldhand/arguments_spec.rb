require 'fieldhand/arguments'
require 'fieldhand/set'
require 'fieldhand/metadata_format'
require 'ox'
require 'date'
require 'time'

module Fieldhand
  RSpec.describe Arguments do
    describe '#to_query' do
      it 'returns a metadata prefix of "oai_dc" by default' do
        arguments = described_class.new

        expect(arguments.to_query).to eq('metadataPrefix' => 'oai_dc')
      end

      it 'allows overriding the metadata prefix' do
        arguments = described_class.new(:metadata_prefix => 'xoai')

        expect(arguments.to_query).to eq('metadataPrefix' => 'xoai')
      end

      it 'allows overriding the metadata prefix with a Metadata Format' do
        format = MetadataFormat.new
        format.prefix = 'xoai'
        arguments = described_class.new(:metadata_prefix => format)

        expect(arguments.to_query).to eq('metadataPrefix' => 'xoai')
      end

      it 'allows passing a resumption token' do
        arguments = described_class.new(:resumption_token => 'foo')

        expect(arguments.to_query).to include('resumptionToken' => 'foo')
      end

      it 'allows passing a from datestamp' do
        arguments = described_class.new(:from => '2001-01-01')

        expect(arguments.to_query).to include('from' => '2001-01-01')
      end

      it 'converts a Date from datestamp to a string' do
        arguments = described_class.new(:from => ::Date.new(2001, 1, 1))

        expect(arguments.to_query).to include('from' => '2001-01-01')
      end

      it 'converts a Time from datestamp to a string' do
        arguments = described_class.new(:from => ::Time.utc(2001, 1, 1, 0, 0, 0))

        expect(arguments.to_query).to include('from' => '2001-01-01T00:00:00Z')
      end

      it 'allows passing an until datestamp' do
        arguments = described_class.new(:until => '2001-01-01')

        expect(arguments.to_query).to include('until' => '2001-01-01')
      end

      it 'converts a Date until datestamp to a string' do
        arguments = described_class.new(:until => ::Date.new(2001, 1, 1))

        expect(arguments.to_query).to include('until' => '2001-01-01')
      end

      it 'converts a Time until datestamp to a string' do
        arguments = described_class.new(:until => ::Time.utc(2001, 1, 1, 0, 0, 0))

        expect(arguments.to_query).to include('until' => '2001-01-01T00:00:00Z')
      end

      it 'allows passing a set spec' do
        arguments = described_class.new(:set => 'A')

        expect(arguments.to_query).to include('set' => 'A')
      end

      it 'allows passing a Set as a set spec' do
        element = ::Ox.parse('<set><setSpec>A</setSpec></set>')
        set = Set.new(element)
        arguments = described_class.new(:set => set)

        expect(arguments.to_query).to include('set' => 'A')
      end

      it 'raises an error when given unknown arguments' do
        arguments = described_class.new(:foo => 'bar')

        expect { arguments.to_query }.to raise_error(::ArgumentError)
      end
    end
  end
end
