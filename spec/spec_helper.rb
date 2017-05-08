require 'webmock/rspec'

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  def stub_oai_request(uri, fixture)
    stub_request(:get, uri).
      to_return(:body => fixture(fixture))
  end

  def fixture(name)
    File.read(File.join(File.expand_path('../fixtures', __FILE__), name))
  end
end
