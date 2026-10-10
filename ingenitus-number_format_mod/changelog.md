# Changelog

## [1.0.0] – 2026-09-25

- Initial release
- Numbers too long for thousands separators (cash, coal, prices) print as short scientific
  notation, e.g. `1.23e10` instead of `1.23457e+10`. Values that round up show `1.00e16`, never
  `10.00e15`. Everything vanilla prints with separators is unchanged.
- Config: `enabled` (default: true)
