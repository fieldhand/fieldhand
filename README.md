# Fieldhand [![Build Status](https://travis-ci.org/altmetric/fieldhand.svg?branch=master)](https://travis-ci.org/altmetric/fieldhand)

A Ruby library for harvesting metadata from [OAI-PMH](https://www.openarchives.org/OAI/openarchivesprotocol.html) repositories.

**Current version:** 0.7.0  
**Supported Ruby versions:** 1.8.7, 1.9.2, 1.9.3, 2.0, 2.1, 2.2

## Installation

```
gem install fieldhand -v '~> 0.7'
```

Or, in your `Gemfile`:

```ruby
gem 'fieldhand', '~> 0.7'
```

## Usage

```ruby
require 'fieldhand'

repository = Fieldhand::Repository.new('http://example.com/oai')
repository.identify.name
#=> "Repository Name"

repository.metadata_formats.map { |format| format.prefix }
#=> ["oai_dc"]

repository.sets.map { |set| set.name }
#=> ["Set A.", "Set B."]

repository.records.each do |record|
  # ...
end

repository.get('oai:www.example.com:12345')
#=> #<Fieldhand::Record: ...>
```

## API Documentation

* [`Fieldhand::Repository`](#fieldhandrepository)
  * [`.new(uri[, logger])`](#fieldhandrepositorynewuri-logger)
  * [`#identify`](#fieldhandrepositoryidentify)
  * [`#metadata_formats([identifier])`](#fieldhandrepositorymetadata_formatsidentifier)
  * [`#sets`](#fieldhandrepositorysets)
  * [`#records([arguments])`](#fieldhandrepositoryrecordsarguments)
  * [`#identifiers([arguments])`](#fieldhandrepositoryidentifiersarguments)
  * [`#get(identifier[, arguments])`](#fieldhandrepositorygetidentifier-arguments)
* [`Fieldhand::Identify`](#fieldhandidentify)
  * [`#name`](#fieldhandidentifyname)
  * [`#base_url`](#fieldhandidentifybase_url)
  * [`#protocol_version`](#fieldhandidentifyprotocol_version)
  * [`#earliest_datestamp`](#fieldhandidentifyearliest_datestamp)
  * [`#deleted_record`](#fieldhandidentifydeleted_record)
  * [`#granularity`](#fieldhandidentifygranularity)
  * [`#admin_emails`](#fieldhandidentifyadmin_emails)
  * [`#compression`](#fieldhandidentifycompression)
  * [`#descriptions`](#fieldhandidentifydescriptions)
  * [`#response_date`](#fieldhandidentifyresponse_date)
* [`Fieldhand::MetadataFormat`](#fieldhandmetadataformat)
  * [`#prefix`](#fieldhandmetadataformatprefix)
  * [`#schema`](#fieldhandmetadataformatschema)
  * [`#namespace`](#fieldhandmetadataformatnamespace)
  * [`#response_date`](#fieldhandmetadataformatresponse_date)
* [`Fieldhand::Set`](#fieldhandset)
  * [`#spec`](#fieldhandsetspec)
  * [`#name`](#fieldhandsetname)
  * [`#descriptions`](#fieldhandsetdescriptions)
  * [`#response_date`](#fieldhandsetresponse_date)
* [`Fieldhand::Record`](#fieldhandrecord)
  * [`#deleted?`](#fieldhandrecorddeleted)
  * [`#status`](#fieldhandrecordstatus)
  * [`#identifier`](#fieldhandrecordidentifier)
  * [`#datestamp`](#fieldhandrecorddatestamp)
  * [`#sets`](#fieldhandrecordsets)
  * [`#to_xml`](#fieldhandrecordto_xml)
  * [`#metadata`](#fieldhandrecordmetadata)
  * [`#about`](#fieldhandrecordabout)
  * [`#response_date`](#fieldhandrecordresponse_date)
* [`Fieldhand::Header`](#fieldhandheader)
  * [`#deleted?`](#fieldhandheaderdeleted)
  * [`#status`](#fieldhandheaderstatus)
  * [`#identifier`](#fieldhandheaderidentifier)
  * [`#datestamp`](#fieldhandheaderdatestamp)
  * [`#sets`](#fieldhandheadersets)
  * [`#response_date`](#fieldhandheaderresponse_date)
* [`Fieldhand::NetworkError`](#fieldhandnetworkerror)
  * [`Fieldhand::ResponseError`](#fieldhandresponseerror)
    * [`Fieldhand::ResponseError#response`](#fieldhandresponseerrorresponse)
* [`Fieldhand::ProtocolError`](#fieldhandprotocolerror)
  * [`Fieldhand::BadArgumentError`](#fieldhandbadargumenterror)
  * [`Fieldhand::BadResumptionTokenError`](#fieldhandbadresumptiontokenerror)
  * [`Fieldhand::BadVerbError`](#fieldhandbadverberror)
  * [`Fieldhand::CannotDisseminateFormatError`](#fieldhandcannotdisseminateformaterror)
  * [`Fieldhand::IdDoesNotExistError`](#fieldhandiddoesnotexisterror)
  * [`Fieldhand::NoRecordsMatchError`](#fieldhandnorecordsmatcherror)
  * [`Fieldhand::NoMetadataFormatsError`](#fieldhandnometadataformatserror)
  * [`Fieldhand::NoSetHierarchyError`](#fieldhandnosethierarchyerror)

### `Fieldhand::Repository`

A class to represent [an OAI-PMH repository](https://www.openarchives.org/OAI/openarchivesprotocol.html#Repository):

> A repository is a network accessible server that can process the 6 OAI-PMH
> requests [...]. A repository is managed by a data provider to expose metadata
> to harvesters.

#### `Fieldhand::Repository.new(uri[, logger])`

```ruby
Fieldhand::Repository.new('http://www.example.com/oai')
Fieldhand::Repository.new(URI('http://www.example.com/oai'))
Fieldhand::Repository.new('http://www.example.com/oai', Logger.new(STDOUT))
```

Return a new [`Repository`](#fieldhandrepository) instance accessible at the given `uri` (specified
either as a [`URI`][URI] or
something that can be coerced into a `URI` such as a `String`) with an optional
[`Logger`](http://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html)-compatible
`logger`.

#### `Fieldhand::Repository#identify`

```ruby
repository.identify
#=> #<Fieldhand::Identify: ...>
```

Return an [`Identify`](#fieldhandidentify) for the repository including information such as the repository name, base URL, protocol version, etc.

May raise a [`NetworkError`](#fieldhandnetworkerror) if there is a problem contacting the repository or any descendant [`ProtocolError`](#fieldhandprotocolerror) if received in response.

#### `Fieldhand::Repository#metadata_formats([identifier])`

```ruby
repository.metadata_formats
#=> #<Enumerator: ...>
repository.metadata_formats('oai:www.example.com:1')
```

Return an [`Enumerator`][Enumerator] of [`MetadataFormat`](#fieldhandmetadataformat)s available from the repository. Optionally takes an `identifier` that specifies the unique identifier of the item for which available metadata formats are being requested.

May raise a [`NetworkError`](#fieldhandnetworkerror) if there is a problem contacting the repository or any descendant [`ProtocolError`](#fieldhandprotocolerror) if received in response.

#### `Fieldhand::Repository#sets`

```ruby
repository.sets
#=> #<Enumerator: ...>
```

Return an [`Enumerator`][Enumerator] of [`Set`](#fieldhandset)s that represent the set structure of a repository.

May raise a [`NetworkError`](#fieldhandnetworkerror) if there is a problem contacting the repository or any descendant [`ProtocolError`](#fieldhandprotocolerror) if received in response.

#### `Fieldhand::Repository#records([arguments])`

```ruby
repository.records
repository.records(:metadata_prefix => 'oai_dc', :from => '2001-01-01')
repository.records(:metadata_prefix => 'oai_dc', :from => Date.new(2001, 1, 1))
repository.records(:set => 'A', :until => Time.utc(2010, 1, 1, 12, 0))
```

Return an [`Enumerator`][Enumerator] of all [`Record`](#fieldhandrecord)s harvested from the repository.

Optional arguments can be passed as a `Hash` of `arguments` to permit selective harvesting of records based on set membership and/or datestamp:

* `:metadata_prefix`: a `String` or [`MetadataFormat`](#fieldhandmetadataformat) to specify the metadata format that should be included in the metadata part of the returned record, defaults to `oai_dc`;
* `:from`: an optional argument with a `String`, [`Date`][Date] or [`Time`][Time] [UTCdatetime](https://www.openarchives.org/OAI/openarchivesprotocol.html#Dates) value, which specifies a lower bound for datestamp-based selective harvesting;
* `:until`: an optional argument with a `String`, [`Date`][Date] or [`Time`][Time] [UTCdatetime](https://www.openarchives.org/OAI/openarchivesprotocol.html#Dates) value, which specifies a upper bound for datestamp-based selective harvesting;
* `:set`: an optional argument with a [set spec](#fieldhandsetspec) value (passed as either a `String` or a [`Set`](#fieldhandset)), which specifies set criteria for selective harvesting;
* `:resumption_token`: an exclusive argument with a `String` value that is the flow control token returned by a previous request that issued an incomplete list.

Note that datetimes should respect the repository's [granularity](#fieldhandidentifygranularity) otherwise they will return a [`BadArgumentError`](#fieldhandbadargumenterror).

May raise a [`NetworkError`](#fieldhandnetworkerror) if there is a problem contacting the repository or any descendant [`ProtocolError`](#fieldhandprotocolerror) if received in response.

#### `Fieldhand::Repository#identifiers(metadata_prefix[, arguments])`

```ruby
repository.identifiers
repository.identifiers(:metadata_prefix => 'oai_dc', :from => '2001-01-01')
repository.identifiers(:metadata_prefix => 'oai_dc', :from => Date.new(2001, 1, 1))
repository.identifiers(:set => 'A', :until => Time.utc(2010, 1, 1, 12, 0))
```

Return an [`Enumerator`][Enumerator] for an abbreviated form of [records](#fieldhandrepositoryrecordsarguments), retrieving only [`Header`](#fieldhandheader)s with the given optional `arguments`.

See [`Fieldhand::Repository#records`](#fieldhandrepositoryrecordsarguments) for supported `arguments`.

May raise a [`NetworkError`](#fieldhandnetworkerror) if there is a problem contacting the repository or any descendant [`ProtocolError`](#fieldhandprotocolerror) if received in response.

#### `Fieldhand::Repository#get(identifier[, arguments])`

```ruby
repository.get('oai:www.example.com:1')
repository.get('oai:www.example.com:1', :metadata_prefix => 'oai_dc')
#=> #<Fieldhand::Record: ...>
```

Return an individual metadata [`Record`](#fieldhandrecord) from a repository with the given `identifier` and optional `:metadata_prefix` argument (defaults to `oai_dc`).

May raise a [`NetworkError`](#fieldhandnetworkerror) if there is a problem contacting the repository or any descendant [`ProtocolError`](#fieldhandprotocolerror) if received in response.

### `Fieldhand::Identify`

A class to represent information about a repository as returned from the [`Identify` request](https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify).

#### `Fieldhand::Identify#name`

```ruby
repository.identify.name
#=> "Repository Name"
```

Return a human readable name for the repository as a `String`.

#### `Fieldhand::Identify#base_url`

```ruby
repository.identify.base_url
#=> #<URI::HTTP http://www.example.com/oai>
```

Returns the [base URL](https://www.openarchives.org/OAI/openarchivesprotocol.html#HTTPRequestFormat) of the repository as a [`URI`][URI].

#### `Fieldhand::Identify#protocol_version`

```ruby
repository.identify.protocol_version
#=> "2.0"
```

Returns the version of the OAI-PMH protocol supported by the repository as a `String`.

#### `Fieldhand::Identify#earliest_datestamp`

```ruby
repository.identify.earliest_datestamp
#=> 2011-01-01 00:00:00 UTC
repository.identify.earliest_datestamp
#=> #<Date: 2001-01-01 ((2451911j,0s,0n),+0s,2299161j)>
```

Returns the guaranteed lower limit of all datestamps recording changes, modifications, or deletions in the repository as a [`Time`][Time] or [`Date`][Date]. Note that the datestamp will be at the finest [granularity](#fieldhandidentifygranularity) supported by the repository.

#### `Fieldhand::Identify#deleted_record`

```ruby
repository.identify.deleted_record
#=> "persistent"
```

Returns the manner in which the repository supports the notion of deleted records as a `String`. Legitimate values are `no`; `transient`; `persistent` with meanings defined in [the section on deletion](https://www.openarchives.org/OAI/openarchivesprotocol.html#DeletedRecords).

#### `Fieldhand::Identify#granularity`

```ruby
repository.identify.granularity
#=> "YYYY-MM-DDThh:mm:ssZ"
```

Returns the finest [harvesting granularity](https://www.openarchives.org/OAI/openarchivesprotocol.html#Datestamp) supported by the repository as a `String`. The legitimate values are `YYYY-MM-DD` and `YYYY-MM-DDThh:mm:ssZ` with meanings as defined in [ISO 8601](http://www.w3.org/TR/NOTE-datetime).

#### `Fieldhand::Identify#admin_emails`

```ruby
repository.identify.admin_emails
#=> ["admin@example.com"]
```

Returns the e-mail addresses of administrators of the repository as an `Array` of `String`s.

#### `Fieldhand::Identify#compression`

```ruby
repository.identify.compression
#=> ["gzip", "deflate"]
```

Returns the compression encodings supported by the repository as an `Array` of `String`s. The recommended values are those defined for the Content-Encoding header in Section 14.11 of [RFC 2616](http://www.ietf.org/rfc/rfc2616.txt) describing HTTP 1.1

#### `Fieldhand::Identify#descriptions`

```ruby
repository.identify.descriptions
#=> ["<description>..."]
```

Returns descriptions of this repository as an `Array` of `String`s.

As descriptions can be in any format, Fieldhand doesn't attempt to parse descriptions but leaves parsing to the client.

#### `Fieldhand::Identify#response_date`

```ruby
repository.identify.response_date
#=> 2017-05-08 11:21:38 +0100
```

Return the time and date that the response was sent.

### `Fieldhand::MetadataFormat`

A class to represent a metadata format available from a repository.

#### `Fieldhand::MetadataFormat#prefix`

```ruby
repository.metadata_formats.first.prefix
#=> "oai_dc"
```

Return the prefix of the metadata format to be used when requesting records as a `String`.

#### `Fieldhand::MetadataFormat#schema`

```ruby
repository.metadata_formats.first.schema
#=> #<URI::HTTP http://www.openarchives.org/OAI/2.0/oai_dc.xsd>
```

Return the location of an XML Schema describing the format as a [`URI`][URI].

#### `Fieldhand::MetadataFormat#namespace`

```ruby
repository.metadata_formats.first.namespace
#=> #<URI::HTTP http://www.openarchives.org/OAI/2.0/oai_dc/>
```

Return the XML Namespace URI for the format as a [`URI`][URI].

#### `Fieldhand::MetadataFormat#response_date`

```ruby
repository.metadata_formats.first.response_date
#=> 2017-05-08 11:21:38 +0100
```

Return the time and date that the response was sent.

### `Fieldhand::Set`

A class representing an optional construct for grouping items for the purpose of selective harvesting.

#### `Fieldhand::Set#spec`

```ruby
repository.sets.first.spec
#=> "A"
```

Return unique identifier for the set which is also the path from the root of the set hierarchy to the respective node as a `String`.

#### `Fieldhand::Set#name`

```ruby
repository.sets.first.name
#=> "Set A."
```

Return a short human-readable `String` naming the set.

#### `Fieldhand::Set#descriptions`

```ruby
repository.sets.first.descriptions
#=> ["<setDescription>..."]
```

Return an `Array` of `String`s of any optional and repeatable containers that may hold community-specific XML-encoded data about the set.

#### `Fieldhand::Set#response_date`

```ruby
repository.sets.first.response_date
#=> 2017-05-08 11:21:38 +0100
```

Return the time and date that the response was sent.

### `Fieldhand::Record`

A class representing a [record](https://www.openarchives.org/OAI/openarchivesprotocol.html#Record) from the repository:

> A record is metadata expressed in a single format.

#### `Fieldhand::Record#deleted?`

```ruby
repository.records.first.deleted?
#=> true
```

Return whether or not a record is [deleted](https://www.openarchives.org/OAI/openarchivesprotocol.html#DeletedRecords) as a `Boolean`.

#### `Fieldhand::Record#status`

```ruby
repository.records.first.status
#=> "deleted"
```

Return the optional `status` attribute of the [record's header](https://www.openarchives.org/OAI/openarchivesprotocol.html#header) as a `String` or `nil`.

> [A] value of deleted indicates the withdrawal of availability of the specified metadata format for the item, dependent on the repository support for deletions.

#### `Fieldhand::Record#identifier`

```ruby
repository.records.first.identifier
#=> "oai:www.example.com:1"
```

Return the [unique identifier](https://www.openarchives.org/OAI/openarchivesprotocol.html#UniqueIdentifier) for this record in the repository.

#### `Fieldhand::Record#datestamp`

```ruby
repository.records.first.datestamp
#=> 2011-03-03 16:29:24 UTC
```

Return the date of creation, modification or deletion of the record for the purpose of selective harvesting as a [`Time`][Time] or [`Date`][Date] depending on the [granularity](#fieldhandidentifygranularity) of the repository.

#### `Fieldhand::Record#sets`

```ruby
repository.records.first.sets
#=> ["A", "B"]
```

Return an `Array` of `String` [set specs](#fieldhandsetspec) indicating set memberships of this record.

#### `Fieldhand::Record#to_xml`

```ruby
repository.records.first.to_xml
#=> "<record><metadata>...</metadata><record>"
```

Return the record as a `String` of XML.

#### `Fieldhand::Record#metadata`

```ruby
repository.records.first.metadata
#=> "<metadata>..."
```

Return a single manifestation of the metadata from a record as a `String` or `nil` if this is a deleted record.

As the metadata can be in [any format supported by the repository](#fieldhandrepositorymetadata_formatsidentifier), Fieldhand doesn't attempt to parse the metadata but leaves parsing to the client.

#### `Fieldhand::Record#about`

```ruby
repository.records.first.about
#=> ["<about>..."]
```

Return an `Array` of `String`s of any optional and repeatable containers holding data about the metadata part of the record.

#### `Fieldhand::Record#response_date`

```ruby
repository.records.first.response_date
#=> 2017-05-08 11:21:38 +0100
```

Return the time and date that the response was sent.

### `Fieldhand::Header`

A class representing the [header](https://www.openarchives.org/OAI/openarchivesprotocol.html#header) of a record:

> Contains the unique identifier of the item and properties necessary for selective harvesting. The header consists of
> the following parts:
>
> * the unique identifier -- the unique identifier of an item in a repository;
> * the datestamp -- the date of creation, modification or deletion of the record for the purpose of selective
>   harvesting.
> * zero or more setSpec elements -- the set membership of the item for the purpose of selective harvesting.
> * an optional status attribute with a value of deleted indicates the withdrawal of availability of the specified
>   metadata format for the item, dependent on the repository support for deletions.

#### `Fieldhand::Header#deleted?`

```ruby
repository.identifiers.first.deleted?
#=> true
```

Return whether or not a record is [deleted](https://www.openarchives.org/OAI/openarchivesprotocol.html#DeletedRecords) as a `Boolean`.

#### `Fieldhand::Header#status`

```ruby
repository.identifiers.first.status
#=> "deleted"
```

Return the optional `status` attribute of the header as a `String` or `nil`.

> [A] value of deleted indicates the withdrawal of availability of the specified metadata format for the item, dependent on the repository support for deletions.

#### `Fieldhand::Header#identifier`

```ruby
repository.identifiers.first.identifier
#=> "oai:www.example.com:1"
```

Return the [unique identifier](https://www.openarchives.org/OAI/openarchivesprotocol.html#UniqueIdentifier) for this record in the repository.

#### `Fieldhand::Header#datestamp`

```ruby
repository.identifiers.first.datestamp
#=> 2011-03-03 16:29:24 UTC
```

Return the date of creation, modification or deletion of the record for the purpose of selective harvesting as a [`Time`][Time] or [`Date`][Date] depending on the [granularity](#fieldhandidentifygranularity) of the repository.

#### `Fieldhand::Header#sets`

```ruby
repository.identifiers.first.sets
#=> ["A", "B"]
```

Return an `Array` of `String` [set specs](#fieldhandsetspec) indicating set memberships of this record.

#### `Fieldhand::Header#response_date`

```ruby
repository.identifiers.first.response_date
#=> 2017-05-08 11:21:38 +0100
```

Return the time and date that the response was sent.

### `Fieldhand::NetworkError`

An error (descended from `StandardError`) to represent any network issues encountered during interaction with the repository. Any underlying exception is exposed in Ruby 2.1 onwards through [`Exception#cause`](https://ruby-doc.org/core-2.1.0/Exception.html#method-i-cause).

### `Fieldhand::ResponseError`

An error (descended from `NetworkError`) to represent any issues in the response from the repository.
If the HTTP request is not successful (returning a status code other than 200),
a `ResponseError` exception will be raised containing the error message and the response object.

#### `Fieldhand::ResponseError#response`

```ruby
begin
  repository.records.each do |record|
    # ...
  end
rescue Fieldhand::ResponseError => e
  puts e.response
  #=> #<Net::HTTPServiceUnavailable 503 Service Unavailable readbody=true>
end
```

Returns the unsuccessful
[`Net::HTTPResponse`](https://ruby-doc.org/stdlib/libdoc/net/http/rdoc/Net/HTTPResponse.html)
that caused this error.

### `Fieldhand::ProtocolError`

The parent error class (descended from `StandardError`) for any errors returned
by a repository as defined in the [protocol's Error and Exception
Conditions](https://www.openarchives.org/OAI/openarchivesprotocol.html#ErrorConditions).

This can be used to rescue all the following child error types.

### `Fieldhand::BadArgumentError`

> The request includes illegal arguments, is missing required arguments,
> includes a repeated argument, or values for arguments have an illegal syntax.

### `Fieldhand::BadResumptionTokenError`

> The value of the `resumptionToken` argument is invalid or expired.

### `Fieldhand::BadVerbError`

> Value of the `verb` argument is not a legal OAI-PMH verb, the `verb` argument is
> missing, or the `verb` argument is repeated.

### `Fieldhand::CannotDisseminateFormatError`

> The metadata format identified by the value given for the `metadataPrefix`
> argument is not supported by the item or by the repository.

### `Fieldhand::IdDoesNotExistError`

> The value of the `identifier` argument is unknown or illegal in this
> repository.

### `Fieldhand::NoRecordsMatchError`

> The combination of the values of the `from`, `until`, `set` and `metadataPrefix`
> arguments results in an empty list.

### `Fieldhand::NoMetadataFormatsError`

> There are no metadata formats available for the specified item.

### `Fieldhand::NoSetHierarchyError`

> The repository does not support sets.

  [Date]: https://ruby-doc.org/stdlib/libdoc/date/rdoc/Date.html
  [Enumerator]: https://ruby-doc.org/core/Enumerator.html
  [Time]: https://ruby-doc.org/core/Time.html
  [URI]: https://ruby-doc.org/stdlib/libdoc/uri/rdoc/URI.html

## Acknowledgements

* Example XML responses are taken from [Datacite's OAI-PMH repository](https://oai.datacite.org/).
* Null device detection is based on the implementation from the [backports](https://github.com/marcandre/backports) gem.
* Much of the documentation relies on wording from version 2.0 of [The Open Archives Initiative Protocol for Metadata Harvesting](https://www.openarchives.org/OAI/openarchivesprotocol.html).

## License

Copyright © 2017 Altmetric LLP

Distributed under the MIT License.
