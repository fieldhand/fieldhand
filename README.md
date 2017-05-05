# Fieldhand [![Build Status](https://travis-ci.org/altmetric/fieldhand.svg?branch=master)](https://travis-ci.org/altmetric/fieldhand)

A Ruby library for harvesting metadata from [OAI-PMH](https://www.openarchives.org/OAI/openarchivesprotocol.html) repositories.

**Current version:** 0.1.0  
**Supported Ruby versions:** 1.8.7, 1.9.2, 1.9.3, 2.0, 2.1, 2.2

## Usage

```ruby
require 'fieldhand'

repository = Fieldhand::Repository.new('http://example.com/oai')

repository.metadata_formats.each do |format|
  puts format.prefix
end

repository.sets.each do |set|
  puts set.name
end

repository.records('oai_dc').each do |record|
  puts record.identifier
end
```

## License

Copyright © 2017 Altmetric LLP

Distributed under the MIT License.
