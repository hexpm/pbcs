# PBCS

[![Hex version](https://img.shields.io/hexpm/v/pbcs.svg "Hex version")](https://hex.pm/packages/pbcs)
[![Build Status](https://travis-ci.org/hexpm/pbcs.svg)](https://travis-ci.org/hexpm/pbcs)

PKCS #5: Password-Based Cryptography Specification Version 2.0

  See: https://tools.ietf.org/html/rfc2898

## Usage

```
protected = %{
  alg: "PBES2-HS512",
  enc: "A256GCM",
  p2c: 4096,
  p2s: :crypto.strong_rand_bytes(32)
}

tag = "ARBITRARY_TAG"

cipher_text = PBCS.encrypt({tag, "Text to encrypt"}, protected, password: "12345")
{:ok, "Text to encrypt"} = PBCS.decrypt({tag, cipher_text}, password: "12345")
```
