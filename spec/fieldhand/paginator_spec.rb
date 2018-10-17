require 'fieldhand/get_record_parser'
require 'fieldhand/identify_parser'
require 'fieldhand/list_metadata_formats_parser'
require 'fieldhand/list_records_parser'
require 'fieldhand/list_sets_parser'
require 'fieldhand/paginator'

module Fieldhand
  RSpec.describe Paginator do
    describe '#items' do
      it 'raises a Bad Argument Error if returned from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=Identify&bad=Argument',
                         'bad_argument_error.xml')
        paginator = described_class.new('http://www.example.com/oai')

        expect { paginator.items('Identify', IdentifyParser, 'bad' => 'Argument').first }.
          to raise_error(BadArgumentError)
      end

      it 'raises a Bad Resumption Token Error if returned from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&resumptionToken=foo',
                         'bad_resumption_token_error.xml')
        paginator = described_class.new('http://www.example.com/oai')

        expect { paginator.items('ListRecords', ListRecordsParser, 'resumptionToken' => 'foo').first }.
          to raise_error(BadResumptionTokenError)
      end

      it 'raises a Bad Verb Error if returned from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=Bad',
                         'bad_verb_error.xml')
        paginator = described_class.new('http://www.example.com/oai')

        expect { paginator.items('Bad', IdentifyParser).first }.
          to raise_error(BadVerbError)
      end

      it 'raises a Cannot Disseminate Format Error if returned from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=bad',
                         'cannot_disseminate_format_error.xml')
        paginator = described_class.new('http://www.example.com/oai')

        expect { paginator.items('ListRecords', ListRecordsParser, 'metadataPrefix' => 'bad').first }.
          to raise_error(CannotDisseminateFormatError)
      end

      it 'raises an ID Does Not Exist Error if returned from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=GetRecord&metadataPrefix=oai_dc&identifier=bad',
                         'id_does_not_exist_error.xml')
        paginator = described_class.new('http://www.example.com/oai')

        expect {
          paginator.items('GetRecord', GetRecordParser, 'metadataPrefix' => 'oai_dc', 'identifier' => 'bad').first
        }.to raise_error(IdDoesNotExistError)
      end

      it 'raises a No Records Match Error if returned from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListRecords&metadataPrefix=oai_dc&from=2999-01-01',
                         'no_records_match_error.xml')
        paginator = described_class.new('http://www.example.com/oai')

        expect {
          paginator.
            items('ListRecords', ListRecordsParser, 'metadataPrefix' => 'oai_dc', 'from' => '2999-01-01').
            first
        }.to raise_error(NoRecordsMatchError)
      end

      it 'raises a No Metadata Formats Error if returned from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListMetadataFormats&identifier=bad',
                         'no_metadata_formats_error.xml')
        paginator = described_class.new('http://www.example.com/oai')

        expect {
          paginator.items('ListMetadataFormats', ListMetadataFormatsParser, 'identifier' => 'bad').first
        }.to raise_error(NoMetadataFormatsError)
      end

      it 'raises a No Set Hierarchy Error if returned from the repository' do
        stub_oai_request('http://www.example.com/oai?verb=ListSets',
                         'no_set_hierarchy_error.xml')
        paginator = described_class.new('http://www.example.com/oai')

        expect { paginator.items('ListSets', ListSetsParser).first }.
          to raise_error(NoSetHierarchyError)
      end

      it 'raises a Response Error if an unsuccessful response is returned' do
        stub_request(:get, 'http://www.example.com/oai?verb=Identify').
          to_return(:status => 503, :body => 'Retry after 5 seconds')
        paginator = described_class.new('http://www.example.com/oai')

        expect { paginator.items('Identify', IdentifyParser).first }.
          to raise_error(ResponseError)
      end

      it 'raises a Response Error containing a response object' do
        stub_request(:get, 'http://www.example.com/oai?verb=Identify').
          to_return(:status => 503, :body => 'Retry after 5 seconds')
        paginator = described_class.new('http://www.example.com/oai')
        error = nil

        begin
          paginator.items('Identify', IdentifyParser).first
        rescue => e
          error = e
        end

        expect(error.response.body).to eq('Retry after 5 seconds')
      end
    end

    describe '#timeout' do
      it 'defaults to 60 seconds' do
        paginator = described_class.new('http://www.example.com/oai')

        expect(paginator.timeout).to eq(60)
      end

      it 'can be overridden with an option' do
        paginator = described_class.new('http://www.example.com/oai', :timeout => 10)

        expect(paginator.timeout).to eq(10)
      end
    end

    describe '#logger' do
      it 'defaults to a null logger' do
        paginator = described_class.new('http://www.example.com/oai')

        expect(paginator.logger).to be_a(::Logger)
      end

      it 'can be overridden with an option' do
        logger = ::Logger.new(STDOUT)
        paginator = described_class.new('http://www.example.com/oai', :logger => logger)

        expect(paginator.logger).to eq(logger)
      end

      it 'can be overridden by passing as a second argument for historic reasons' do
        logger = ::Logger.new(STDOUT)
        paginator = described_class.new('http://www.example.com/oai', logger)

        expect(paginator.logger).to eq(logger)
      end
    end

    describe '#headers' do
      it 'defaults to an empty hash' do
        paginator = described_class.new('http://www.example.com/oai')

        expect(paginator.headers).to be_empty
      end

      it 'can be overridden with an option' do
        paginator = described_class.new('http://www.example.com/oai', :headers => { 'Crossref-Plus-API-Token' => 'Bearer decafbad' })

        expect(paginator.headers).to eq({ 'Crossref-Plus-API-Token' => 'Bearer decafbad' })
      end

      it 'can add custom headers to HTTP request' do
        request = stub_oai_request('http://www.example.com/oai?verb=Identify', 'identify.xml').
                    with(:headers => { 'Crossref-Plus-API-Token' => 'Bearer decafbad' })
        paginator = described_class.new('http://www.example.com/oai', :headers => { 'Crossref-Plus-API-Token' => 'Bearer decafbad' })

        paginator.items('Identify', IdentifyParser).first

        expect(request).to have_been_requested
      end

      it 'sends an authorization header with a bearer token' do
        request = stub_oai_request('http://www.example.com/oai?verb=Identify', 'identify.xml').
                    with(:headers => { 'Authorization' => 'Bearer ewterhtr' })
        paginator = described_class.new('http://www.example.com/oai', :bearer_token => 'ewterhtr')

        paginator.items('Identify', IdentifyParser).first

        expect(request).to have_been_requested
      end

      it 'can add multiple custom headers to HTTP request' do
        request = stub_oai_request('http://www.example.com/oai?verb=Identify', 'identify.xml').
                    with(:headers => { 'Authorization' => 'Bearer ewterhtr', 'Crossref-Plus-API-Token' => 'decafbad' })
        paginator = described_class.new('http://www.example.com/oai', :bearer_token => 'ewterhtr', :headers => { 'Crossref-Plus-API-Token' => 'decafbad' })

        paginator.items('Identify', IdentifyParser).first

        expect(request).to have_been_requested
      end
    end
  end
end
