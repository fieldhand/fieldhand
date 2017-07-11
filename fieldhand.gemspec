Gem::Specification.new do |s|
  s.name = 'fieldhand'
  s.version = '0.5.0'
  s.summary = 'An OAI-PMH harvester'
  s.description = <<-EOF
    A library to harvest metadata from OAI-PMH repositories.
  EOF
  s.license = 'MIT'
  s.authors = ['Paul Mucur', 'Maciej Gajewski', 'Giovanni Derks']
  s.email = 'support@altmetric.com'
  s.homepage = 'https://github.com/altmetric/fieldhand'
  s.files = %w[README.md LICENSE] + Dir['lib/**/*.rb']
  s.test_files = Dir['spec/**/*.rb']

  s.add_dependency('ox', '~> 2.5')
  s.add_development_dependency('rspec', '~> 3.6')
  s.add_development_dependency('webmock', '~> 1.21', '< 1.22')
  s.add_development_dependency('addressable', '~> 2.3', '< 2.4')
end
