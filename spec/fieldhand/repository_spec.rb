require 'fieldhand/repository'

module Fieldhand
  RSpec.describe Repository do
    describe '#metadata_formats' do
      it 'returns the supported metadata formats for this repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListMetadataFormats', 'list_metadata_formats.xml')
        repository = described_class.new('http://www.example.com/oai')
        formats = repository.metadata_formats.to_a

        expect(formats.size).to eq(1)
      end

      it 'populates metadata formats with the right information' do
        stub_oai_request('http://www.example.com/oai?verb=ListMetadataFormats', 'list_metadata_formats.xml')
        repository = described_class.new('http://www.example.com/oai')
        format = repository.metadata_formats.first

        expect(format).to have_attributes(:prefix => 'oai_dc',
                                          :schema => URI('http://www.openarchives.org/OAI/2.0/oai_dc.xsd'),
                                          :namespace => URI('http://www.openarchives.org/OAI/2.0/oai_dc/'))
      end

      it 'raises an error if the connection times out' do
        stub_request(:get, 'http://www.example.com/oai?verb=ListMetadataFormats').
          to_timeout
        repository = described_class.new('http://www.example.com/oai')

        expect { repository.metadata_formats.to_a }.to raise_error(NetworkError)
      end

      it 'raises an error if the connection resets' do
        stub_request(:get, 'http://www.example.com/oai?verb=ListMetadataFormats').
          to_raise(::Errno::ECONNRESET)
        repository = described_class.new('http://www.example.com/oai')

        expect { repository.metadata_formats.to_a }.to raise_error(NetworkError)
      end

      it 'raises an error if the host is unreachable' do
        stub_request(:get, 'http://www.example.com/oai?verb=ListMetadataFormats').
          to_raise(::Errno::EHOSTUNREACH)
        repository = described_class.new('http://www.example.com/oai')

        expect { repository.metadata_formats.to_a }.to raise_error(NetworkError)
      end

      it 'supports an optional identifier argument' do
        stub_oai_request('http://www.example.com/oai?verb=ListMetadataFormats&identifier=foobar',
                         'list_metadata_formats.xml')
        repository = described_class.new('http://www.example.com/oai')

        repository.metadata_formats('foobar').to_a
      end
    end

    describe '#sets' do
      it 'returns the sets for this repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListSets', 'list_sets_2.xml')
        repository = described_class.new('http://www.example.com/oai')
        set_b = repository.sets.first

        expect(set_b).to have_attributes(:spec => 'B', :name => 'Set B.')
      end

      it 'paginates over all sets for this repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListSets', 'list_sets_1.xml')
        stub_oai_request('http://www.example.com/oai?verb=ListSets&resumptionToken=foobar', 'list_sets_2.xml')
        repository = described_class.new('http://www.example.com/oai')
        sets = repository.sets.to_a

        expect(sets.size).to eq(2)
      end

      it 'raises an error if the connection times out while consuming' do
        stub_request(:get, 'http://www.example.com/oai?verb=ListSets').to_timeout
        repository = described_class.new('http://www.example.com/oai')

        expect { repository.sets.to_a }.to raise_error(NetworkError)
      end
    end

    describe '#records' do
      it 'defaults to using a metadata prefix of oai_dc' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=oai_dc', 'list_records_1.xml')
        repository = described_class.new('http://www.example.com/oai')

        repository.records.first
      end

      it 'returns all records for this repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=oai_dc', 'list_records_1.xml')
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&resumptionToken=foobar', 'list_records_2.xml')
        repository = described_class.new('http://www.example.com/oai')
        records = repository.records(:metadata_prefix => 'oai_dc').to_a

        expect(records.size).to eq(4)
      end

      it 'populates records with the right information' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=oai_dc', 'list_records_1.xml')
        repository = described_class.new('http://www.example.com/oai')
        record = repository.records.first

        expect(record).to have_attributes(:identifier => 'oai:oai.datacite.org:32355',
                                          :datestamp => ::Time.xmlschema('2011-07-07T11:19:03Z'),
                                          :sets => %w[TIB TIB.DAGST])
      end

      it 'populates deleted records with the right information' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=oai_dc', 'list_records_2.xml')
        repository = described_class.new('http://www.example.com/oai')
        record = repository.records.first

        expect(record).to have_attributes(:status => 'deleted',
                                          :datestamp => ::Time.xmlschema('2011-03-04T14:18:47Z'),
                                          :sets => %w[BL BL.WAP])
      end

      it 'supports passing extra arguments to the request' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=oai_dc&from=2001-01-01&until=2002-01-01',
                         'list_records_2.xml')
        repository = described_class.new('http://www.example.com/oai')

        repository.records(:from => '2001-01-01', :until => '2002-01-01')
      end

      it 'returns all records for repository with namespace' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=marcxml', 'list_records_with_namespaces.xml')
        repository = described_class.new('http://www.example.com/oai')

        records = repository.records(:metadata_prefix => 'marcxml').to_a
        expect(records.size).to eq(2)
      end

      it 'populates records with the right information for repository with namespace' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=marcxml', 'list_records_with_namespaces.xml')
        repository = described_class.new('http://www.example.com/oai')
        record = repository.records(:metadata_prefix => 'marcxml').first

        expect(record).to have_attributes(:identifier => '123456',
                                          :datestamp => ::Date.strptime('2018-11-08'),
                                          :sets => %w[],
                                          :deleted? => false,
                                          :status => nil,
                                          :about => [],
                                          :metadata => "<metadata><collection><record/></collection></metadata>\n"
                                          )
      end
    end

    describe '#identifiers' do
      it 'defaults to a metadata prefix of "oai_dc"' do
        stub_oai_request('http://www.example.com/oai?verb=ListIdentifiers&metadataPrefix=oai_dc',
                         'list_identifiers.xml')
        repository = described_class.new('http://www.example.com/oai')

        repository.identifiers.first
      end

      it 'returns all headers from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListIdentifiers&metadataPrefix=oai_dc',
                         'list_identifiers.xml')
        repository = described_class.new('http://www.example.com/oai')
        headers = repository.identifiers(:metadata_prefix => 'oai_dc').to_a

        expect(headers.size).to eq(2)
      end
    end

    describe '#identify' do
      it 'returns information about the repository' do
        stub_oai_request('http://www.example.com/oai?verb=Identify', 'identify.xml')
        repository = described_class.new('http://www.example.com/oai')
        identify = repository.identify

        expect(identify).to have_attributes(:name => 'DataCite MDS',
                                            :base_url => URI('http://oai.datacite.org/oai'),
                                            :protocol_version => '2.0',
                                            :earliest_datestamp => ::Time.xmlschema('2011-01-01T00:00:00Z'),
                                            :deleted_record => 'persistent',
                                            :granularity => 'YYYY-MM-DDThh:mm:ssZ',
                                            :admin_emails => %w[admin@datacite.org],
                                            :compression => %w[gzip deflate])
      end

      it 'supports HTTPS repositories' do
        stub_oai_request('https://www.example.com/oai?verb=Identify', 'identify.xml')
        repository = described_class.new('https://www.example.com/oai')

        expect(repository.identify).not_to be_nil
      end
    end

    describe '#get' do
      it 'defaults to a metadata prefix of "oai_dc"' do
        stub_oai_request('http://www.example.com/oai?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:oai.datacite.org:32356',
                         'get_record.xml')
        repository = described_class.new('http://www.example.com/oai')

        repository.get('oai:oai.datacite.org:32356')
      end

      it 'fetches the record by identifier' do
        stub_oai_request('http://www.example.com/oai?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:oai.datacite.org:32356',
                         'get_record.xml')
        repository = described_class.new('http://www.example.com/oai')

        expect(repository.get('oai:oai.datacite.org:32356', :metadata_prefix => 'oai_dc')).
          to have_attributes(:identifier => 'oai:oai.datacite.org:32356')
      end

      it 'fetches the record by identifier' do
        stub_oai_request('http://www.example.com/oai?verb=GetRecord&metadataPrefix=marcxml&identifier=123456',
                         'get_record_with_namespace.xml')
        repository = described_class.new('http://www.example.com/oai')

        expect(repository.get('123456', :metadata_prefix => 'marcxml')).
          to have_attributes(:identifier => '123456')
      end
    end

    describe '#timeout' do
      it 'defaults to 60 seconds' do
        repository = described_class.new('http://www.example.com/oai')

        expect(repository.timeout).to eq(60)
      end

      it 'can be overridden with an option' do
        repository = described_class.new('http://www.example.com/oai', :timeout => 10)

        expect(repository.timeout).to eq(10)
      end
    end

    describe '#logger' do
      it 'defaults to a null logger' do
        repository = described_class.new('http://www.example.com/oai')

        expect(repository.logger).to be_a(::Logger)
      end

      it 'can be overridden with an option' do
        logger = ::Logger.new(STDOUT)
        repository = described_class.new('http://www.example.com/oai', :logger => logger)

        expect(repository.logger).to eq(logger)
      end

      it 'can be overridden by passing as a second argument for historic reasons' do
        logger = ::Logger.new(STDOUT)
        repository = described_class.new('http://www.example.com/oai', logger)

        expect(repository.logger).to eq(logger)
      end
    end

    describe '#headers' do
      it 'defaults to an empty hash' do
        repository = described_class.new('http://www.example.com/oai')

        expect(repository.headers).to be_empty
      end

      it 'can be overridden with an option' do
        repository = described_class.new('http://www.example.com/oai', :headers => { 'Crossref-Plus-API-Token' => 'Bearer decafbad' })

        expect(repository.headers).to eq({ 'Crossref-Plus-API-Token' => 'Bearer decafbad' })
      end

      it 'can add custom headers to HTTP request' do
        request = stub_oai_request('http://www.example.com/oai?verb=Identify', 'identify.xml').
                   with(:headers => { 'Crossref-Plus-API-Token' => 'Bearer decafbad' })
        repository = described_class.new('http://www.example.com/oai', :headers => { 'Crossref-Plus-API-Token' => 'Bearer decafbad' })

        repository.identify

        expect(request).to have_been_requested
      end

      it 'can use a bearer token to authorize HTTP requests' do
        request = stub_oai_request('http://www.example.com/oai?verb=Identify', 'identify.xml').
                    with(:headers => { 'Authorization' => 'Bearer fhsfag' })
        repository = described_class.new('http://www.example.com/oai', :bearer_token => 'fhsfag')

        repository.identify

        expect(request).to have_been_requested
      end
    end
  end
end
