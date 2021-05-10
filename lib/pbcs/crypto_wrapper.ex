defmodule PBCS.CryptoWrapper do
  @moduledoc false
  # :crypto.mac/4 is introduced in Erlang/OTP 22.1 and :crypto.hmac/{3,4} are removed
  # in Erlang/OTP 24. The check is needed for backwards compatibility.
  Code.ensure_loaded?(:crypto) || IO.warn(":crypto module failed to load")

  case function_exported?(:crypto, :mac, 4) do
    true ->
      def hmac(type, key, data), do: :crypto.mac(:hmac, type, key, data)

    false ->
      def hmac(type, key, data), do: :crypto.hmac(type, key, data)
  end

  # Support new and old style AES-CBC calls.
  case function_exported?(:crypto, :crypto_one_time, 5) do
    true ->
      def block_decrypt(cipher, key, iv, cipher_text),
        do: :crypto.crypto_one_time(cipher, key, iv, cipher_text, encrypt: false)

      def block_encrypt(cipher, key, iv, plain_text),
        do: :crypto.crypto_one_time(cipher, key, iv, plain_text, encrypt: true)

    false ->
      def block_decrypt(cipher, key, iv, cipher_text) do
        :crypto.block_decrypt(cipher, key, iv, cipher_text)
      rescue
        FunctionClauseError ->
          key
          |> bit_size()
          |> bit_size_to_cipher()
          |> :crypto.block_decrypt(key, iv, cipher_text)
      end

      def block_encrypt(cipher, key, iv, plain_text) do
        :crypto.block_encrypt(cipher, key, iv, plain_text)
      rescue
        FunctionClauseError ->
          key
          |> bit_size()
          |> bit_size_to_cipher()
          |> :crypto.block_encrypt(key, iv, plain_text)
      end

      defp bit_size_to_cipher(128), do: :aes_cbc128
      defp bit_size_to_cipher(192), do: :aes_cbc192
      defp bit_size_to_cipher(256), do: :aes_cbc256
  end
end
