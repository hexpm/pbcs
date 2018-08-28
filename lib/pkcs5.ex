defmodule PKCS5 do
  @moduledoc ~S"""
  PKCS #5: Password-Based Cryptography Specification Version 2.0

  See: https://tools.ietf.org/html/rfc2898
  """

  alias PKCS5.Utils
  alias PKCS5.ContentEncryptor
  alias PKCS5.KeyManager

  def encrypt({tag, plain_text}, protected, opts) do
    case KeyManager.encrypt(protected, opts) do
      {:ok, protected, key, encrypted_key, content_encryptor} ->
        iv = ContentEncryptor.generate_iv(content_encryptor)
        protected = :erlang.term_to_binary(protected)
        aad = tag <> protected

        {cipher_text, cipher_tag} =
          ContentEncryptor.encrypt(content_encryptor, key, iv, {aad, plain_text})

        %{
          protected: protected,
          encrypted_key: encrypted_key,
          iv: iv,
          cipher_text: cipher_text,
          cipher_tag: cipher_tag
        }
        |> :erlang.term_to_binary()
        |> Utils.base64url_encode()

      encrypt_init_error ->
        encrypt_init_error
    end
  end

  def decrypt({tag, cipher_text}, opts) do
    {:ok, cipher_text} = Utils.base64url_decode(cipher_text)

    %{
      protected: protected,
      encrypted_key: encrypted_key,
      iv: iv,
      cipher_text: cipher_text,
      cipher_tag: cipher_tag
    } = Utils.safe_binary_to_term!(cipher_text, [:safe])

    aad = tag <> protected
    protected = Utils.safe_binary_to_term!(protected, [:safe])

    case KeyManager.decrypt(protected, encrypted_key, opts) do
      {:ok, key, content_encryptor} ->
        ContentEncryptor.decrypt(content_encryptor, key, iv, {aad, cipher_text, cipher_tag})

      decrypt_init_error ->
        decrypt_init_error
    end
  rescue
    ArgumentError ->
      :error
  end

  def pbkdf2(password, salt, iterations, derived_key_length, hash)
      when is_binary(password) and is_binary(salt) and is_integer(iterations) and iterations >= 1 and
             is_integer(derived_key_length) and derived_key_length >= 0 do
    hash_length = byte_size(:crypto.hmac(hash, <<>>, <<>>))

    if derived_key_length > 0xFFFFFFFF * hash_length do
      raise ArgumentError, "derived key too long"
    else
      rounds = ceildiv(derived_key_length, hash_length)

      <<derived_key::binary-size(derived_key_length), _::binary>> =
        pbkdf2_iterate(password, salt, iterations, hash, 1, rounds, "")

      derived_key
    end
  end

  defp ceildiv(a, b) do
    div(a, b) + if rem(a, b) === 0, do: 0, else: 1
  end

  defp pbkdf2_iterate(password, salt, iterations, hash, rounds, rounds, derived_keying_material) do
    derived_keying_material <>
      pbkdf2_exor(password, salt, iterations, hash, 1, rounds, <<>>, <<>>)
  end

  defp pbkdf2_iterate(password, salt, iterations, hash, counter, rounds, derived_keying_material) do
    derived_keying_material =
      derived_keying_material <>
        pbkdf2_exor(password, salt, iterations, hash, 1, counter, <<>>, <<>>)

    pbkdf2_iterate(password, salt, iterations, hash, counter + 1, rounds, derived_keying_material)
  end

  defp pbkdf2_exor(_password, _salt, iterations, _hash, i, _counter, _prev, curr)
       when i > iterations do
    curr
  end

  defp pbkdf2_exor(password, salt, iterations, hash, i = 1, counter, <<>>, <<>>) do
    next =
      :crypto.hmac(hash, password, <<salt::binary, counter::1-unsigned-big-integer-unit(32)>>)

    pbkdf2_exor(password, salt, iterations, hash, i + 1, counter, next, next)
  end

  defp pbkdf2_exor(password, salt, iterations, hash, i, counter, prev, curr) do
    next = :crypto.hmac(hash, password, prev)
    curr = :crypto.exor(next, curr)
    pbkdf2_exor(password, salt, iterations, hash, i + 1, counter, next, curr)
  end
end
