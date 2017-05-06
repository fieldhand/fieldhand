# Fieldhand [![Build Status](https://travis-ci.org/altmetric/fieldhand.svg?branch=master)](https://travis-ci.org/altmetric/fieldhand)

A Ruby library for harvesting metadata from [OAI-PMH](https://www.openarchives.org/OAI/openarchivesprotocol.html) repositories.

**Current version:** 0.1.0  
**Supported Ruby versions:** 1.8.7, 1.9.2, 1.9.3, 2.0, 2.1, 2.2

## Usage

```ruby
require 'fieldhand'

repository = Fieldhand::Repository.new('http://example.com/oai')
# or, if you want to log information to STDOUT
repository = Fieldhand::Repository.new('http://example.com/oai', Logger.new(STDOUT))

repository.identify.name
#=> "Repository Name"

repository.metadata_formats.each do |format|
  puts format.prefix
end

repository.sets.each do |set|
  puts set.name
end

repository.records('oai_dc').each do |record|
  puts record.identifier
end

repository.identifiers('oai_dc').each do |header|
  puts header.identifier
end
```

## Acknowledgements

* Example XML responses are taken from [Datacite's OAI-PMH repository](https://oai.datacite.org/).
* Null device detection is based on the implementation from the [backports](https://github.com/marcandre/backports) gem.

## License

Copyright © 2017 Altmetric LLP

Distributed under the MIT License.
