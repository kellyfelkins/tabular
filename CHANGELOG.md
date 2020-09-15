# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2020-09-15

### Changed

- Improves documentation.

## [1.2.0] - 2020-09-14

### Added

- Adds processing of tables that do not have separator lines.

## [1.1.0] - 2019-07-31

### Added

- This changelog.

### Changed

- Merges [PR](https://github.com/kellyfelkins/tabular/pull/4) from
  [@achoe314](https://github.com/achoe314) that deprecates 
  `_no_header` readers while adding a 
  header: true/false option to readers.
    
## [1.0.0] - 2019-07-30

### Added

- `TestSupport.assert_equal(results_table)` returns true when
  no differences are found in the results table, and does a fail
  with a failure message that displays a table with differences
  highlighted. Thank you [@aarongraham](https://github.com/aarongraham).
  

### Changed

- `TestSupport.compare(table1, table2)` now returns all cell values,
  and tuples in the case where cell contents do not match.
  `TestSupport.equal?()` accepts this new format. Thank you 
  [@aarongraham](https://github.com/aarongraham).

