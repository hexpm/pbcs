# PBCS

[![Hex version](https://img.shields.io/hexpm/v/pbcs.svg "Hex version")](https://hex.pm/packages/pbcs)
[![CI](https://github.com/hexpm/hexpm/workflows/CI/badge.svg)](https://github.com/hexpm/pbcs/actions?query=workflow%3ACI)

The PBCS library securely protects secrets using passwords by following the
style and recommendations in [PKCS #5 2.1](https://tools.ietf.org/html/rfc8018).
As in PKCS #5, this library uses a salt to protect against dictionary attacks
and iterates the key derivation function to increase the computation cost of
attacks. These parameters and the cryptographic algorithms used are
configurable.

Key derivation algorithms include:

* `PBES2-HS512`, `PBES2-HS384`, `PBES2-HS256` - PBES2 and HMAC-SHA-2. See [RFC 7518 4.8](https://tools.ietf.org/html/rfc7518#section-4.8) and [RFC 2898 6.2](https://tools.ietf.org/html/rfc2898#section-6.2)

Content encryption algorithms include:

* `A256GCM`, `A192GCM`, `A128GCM` - AES GCM. See [RFC 7518 5.3](https://tools.ietf.org/html/rfc7518#section-5.3)
* `A256CBC-HS512`, `A192CBC-HS384`, `A128CBC-HS256` - AES_CBC_HMAC_SHA2. See [RFC 7518 5.2.6](https://tools.ietf.org/html/rfc7518#section-5.2.6)

## Installation

Add pbcs to the `deps` section of your mix.exs file:

```elixir
def deps do
  [
    {:pbcs, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
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
