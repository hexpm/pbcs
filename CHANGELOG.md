# Changelog

## v0.1.4

* Bug fixes
  * Use old style cipher atoms for calls to `crypto:crypto_one_time_aead`.
    `crypto_one_time_aead` was introduced in OTP 22 but requires ciphers to
    be passed with the key length, such as `aes_128_gcm`. OTP 24 supports
    the use of the cipher `aes_gcm` where the length if inferred from the
    key, but this doesn't work for 22/23.

## v0.1.3

* Enhancements
  * Update crypto API calls for OTP 24 support

## v0.1.2

* Enhancements
  * Clean up Elixir 1.11 warnings

## v0.1.1

* Bug fixes
  * Various updates to specs and docs

## v0.1.0

Initial release
The code originated from the [hex](https://github.com/hexpm/hex)
