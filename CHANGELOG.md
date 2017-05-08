# Change Log
All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

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
