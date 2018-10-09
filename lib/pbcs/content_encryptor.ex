defmodule PBCS.ContentEncryptor do
  @moduledoc """
  Callback module for content encryptors.

  Implement this behaviour if you want to implement your own content encryptor.
  """

  alias PBCS
  alias __MODULE__

  @type t :: %ContentEncryptor{
          module: module,
          params: any
        }

  defstruct module: nil,
            params: nil

  @callback init(protected :: map, opts :: Keyword.t()) :: {:ok, any} | {:error, String.t()}

  @callback encrypt(
              params :: any,
              key :: binary,
              iv :: binary,
              {aad :: binary, plain_text :: binary}
            ) :: {binary, binary}

  @callback decrypt(
              params :: any,
              key :: binary,
              iv :: binary,
              {aad :: binary, cipher_text :: binary, cipher_tag :: binary}
            ) :: {:ok, binary} | :error

  @callback generate_key(params :: any) :: binary

  @callback generate_iv(params :: any) :: binary

  @callback key_length(params :: any) :: non_neg_integer

  def init(protected = %{enc: enc}, opts) do
    case content_encryptor_module(enc) do
      :error ->
        {:error, "Unrecognized ContentEncryptor algorithm: #{inspect(enc)}"}

      module ->
        case module.init(protected, opts) do
          {:ok, params} ->
            content_encryptor = %ContentEncryptor{module: module, params: params}
            {:ok, content_encryptor}

          content_encryptor_error ->
            content_encryptor_error
        end
    end
  end

  @spec encrypt(PBCS.ContentEncryptor.t(), binary(), binary(), {binary(), PBCS.plain_text()}) ::
          {binary(), PBCS.cipher_text()}
  def encrypt(%ContentEncryptor{module: module, params: params}, key, iv, {aad, plain_text}) do
    module.encrypt(params, key, iv, {aad, plain_text})
  end

  @spec decrypt(
          PBCS.ContentEncryptor.t(),
          binary(),
          binary(),
          {binary(), PBCS.cipher_text(), binary()}
        ) :: {:ok, PBCS.plain_text()} | :error
  def decrypt(
        %ContentEncryptor{module: module, params: params},
        key,
        iv,
        {aad, cipher_text, cipher_tag}
      ) do
    module.decrypt(params, key, iv, {aad, cipher_text, cipher_tag})
  end

  @spec generate_key(PBCS.ContentEncryptor.t()) :: binary()
  def generate_key(%ContentEncryptor{module: module, params: params}) do
    module.generate_key(params)
  end

  @spec generate_iv(PBCS.ContentEncryptor.t()) :: binary()
  def generate_iv(%ContentEncryptor{module: module, params: params}) do
    module.generate_iv(params)
  end

  @spec key_length(PBCS.ContentEncryptor.t()) :: pos_integer()
  def key_length(%ContentEncryptor{module: module, params: params}) do
    module.key_length(params)
  end

  defp content_encryptor_module("A128CBC-HS256"), do: PBCS.AES_CBC_HMAC_SHA2
  defp content_encryptor_module("A192CBC-HS384"), do: PBCS.AES_CBC_HMAC_SHA2
  defp content_encryptor_module("A256CBC-HS512"), do: PBCS.AES_CBC_HMAC_SHA2
  defp content_encryptor_module("A128GCM"), do: PBCS.AES_GCM
  defp content_encryptor_module("A192GCM"), do: PBCS.AES_GCM
  defp content_encryptor_module("A256GCM"), do: PBCS.AES_GCM
  defp content_encryptor_module(_), do: :error
end
