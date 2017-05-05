require 'fieldhand/repository'

module Fieldhand
  RSpec.describe Repository do
    describe '#metadata_formats' do
      it 'returns the supported metadata formats for this repository' do
        stub_oai_request('http://example.com/oai?verb=ListMetadataFormats', 'list_metadata_formats.xml')
        repository = described_class.new('http://example.com/oai')
        oai_dc = MetadataFormat.new('oai_dc',
                                    'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
                                    'http://www.openarchives.org/OAI/2.0/oai_dc/')

        expect(repository.metadata_formats).to contain_exactly(oai_dc)
      end

      it 'raises an error if the connection times out' do
        stub_request(:get, 'http://example.com/oai?verb=ListMetadataFormats').
          to_timeout
        repository = described_class.new('http://example.com/oai')

        expect { repository.metadata_formats.to_a }.to raise_error(NetworkError)
      end

      it 'raises an error if the connection resets' do
        stub_request(:get, 'http://example.com/oai?verb=ListMetadataFormats').
          to_raise(::Errno::ECONNRESET)
        repository = described_class.new('http://example.com/oai')

        expect { repository.metadata_formats.to_a }.to raise_error(NetworkError)
      end

      it 'raises an error if the host is unreachable' do
        stub_request(:get, 'http://example.com/oai?verb=ListMetadataFormats').
          to_raise(::Errno::EHOSTUNREACH)
        repository = described_class.new('http://example.com/oai')

        expect { repository.metadata_formats.to_a }.to raise_error(NetworkError)
      end
    end

    describe '#sets' do
      it 'returns the sets for this repository' do
        stub_oai_request('http://example.com/oai?verb=ListSets', 'list_sets_2.xml')
        repository = described_class.new('http://example.com/oai')
        set_b = Set.new('B', 'Set B.')

        expect(repository.sets).to contain_exactly(set_b)
      end

      it 'paginates over all sets for this repository' do
        stub_oai_request('http://example.com/oai?verb=ListSets', 'list_sets_1.xml')
        stub_oai_request('http://example.com/oai?verb=ListSets&resumptionToken=foobar', 'list_sets_2.xml')
        repository = described_class.new('http://example.com/oai')
        set_a = Set.new('A', 'Set A.')
        set_b = Set.new('B', 'Set B.')

        expect(repository.sets).to contain_exactly(set_a, set_b)
      end

      it 'raises an error if the connection times out while consuming' do
        stub_request(:get, 'http://example.com/oai?verb=ListSets').to_timeout
        repository = described_class.new('http://example.com/oai')

        expect { repository.sets.to_a }.to raise_error(NetworkError)
      end
    end

    describe '#records' do
      it 'returns all records for this repository' do
        stub_oai_request('http://example.com/oai?verb=ListRecords&metadataPrefix=oai_dc', 'list_records_1.xml')
        stub_oai_request('http://example.com/oai?verb=ListRecords&metadataPrefix=oai_dc&resumptionToken=foobar', 'list_records_2.xml')
        repository = described_class.new('http://example.com/oai')
        records = repository.records('oai_dc').to_a

        expect(records.size).to eq(4)
      end

      it 'populates records with the right information' do
        stub_oai_request('http://example.com/oai?verb=ListRecords&metadataPrefix=oai_dc', 'list_records_1.xml')
        repository = described_class.new('http://example.com/oai')
        record = repository.records('oai_dc').first

        expect(record).to have_attributes(:identifier => 'oai:oai.datacite.org:32355',
                                          :datestamp => Time.xmlschema('2011-07-07T11:19:03Z'),
                                          :sets => %w[TIB TIB.DAGST])
      end

      it 'populates deleted records with the right information' do
        stub_oai_request('http://example.com/oai?verb=ListRecords&metadataPrefix=oai_dc', 'list_records_2.xml')
        repository = described_class.new('http://example.com/oai')
        record = repository.records('oai_dc').first

        expect(record).to have_attributes(:status => 'deleted',
                                          :datestamp => Time.xmlschema('2011-03-04T14:18:47Z'),
                                          :sets => %w[BL BL.WAP])
      end
    end
  end
end
