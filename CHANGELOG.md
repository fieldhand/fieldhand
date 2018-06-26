# Change Log
All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

## [0.9.0] - 2018-06-26
### Added
- Added option to Repository for HTTP authorization with a bearer token

## [0.8.0] - 2018-05-12
### Added
- Added option to Repository for configuring HTTP timeouts

## [0.7.0] - 2017-07-27
### Changed
- Changed methods that output the string version of xml to return a compressed version of the xml

## [0.6.0] - 2017-07-26
### Added
- Added support for retrieving a Fieldhand record as a string
- Added unicode character support for retrieving Fieldhand record metadata as a string

## [0.5.0] - 2017-07-11
### Changed
- Fieldhand will raise a new subclass of Network Error for unexpected
  responses: Response Error

## [0.4.0] - 2017-07-10
### Changed
- Fieldhand will now raise a Network Error if any response returns unsuccessfully.
- Network Errors can now contain an HTTP response for use by the user.

## [0.3.1] - 2017-05-10
### Added
- Added support for passing DateTimes and any object that responds to xmlschema
  as a datestamp.

## [0.3.0] - 2017-05-08
### Changed
- Changed any method that returned Ox Elements (set descriptions, record
  metadata and record about sections) to now return Strings instead in an
  attempt to loosen our coupling with a third-party dependency and leave XML
  parsing of those data to the user.

## [0.2.0] - 2017-05-08
### Added
- Added response dates to all return types.

## [0.1.0] - 2017-05-07
### Added
- First stable version of Fieldhand and its API for harvesting OAI-PMH repositories.

[0.1.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.1.0
[0.2.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.2.0
[0.3.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.3.0
[0.3.1]: https://github.com/altmetric/fieldhand/releases/tag/v0.3.1
[0.4.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.4.0
[0.5.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.5.0
[0.6.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.6.0
[0.7.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.7.0
[0.8.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.8.0
[0.9.0]: https://github.com/altmetric/fieldhand/releases/tag/v0.9.0
