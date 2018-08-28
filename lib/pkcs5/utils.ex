defmodule PKCS5.Utils do
  def base64url_encode(binary) do
    try do
      Base.url_encode64(binary, padding: false)
    catch
      _, _ ->
        binary
        |> Base.encode64()
        |> urlsafe_encode64(<<>>)
    end
  end

  def base64url_decode(binary) do
    try do
      Base.url_decode64(binary, padding: false)
    catch
      _, _ ->
        try do
          binary = urlsafe_decode64(binary, <<>>)

          binary =
            case rem(byte_size(binary), 4) do
              2 -> binary <> "=="
              3 -> binary <> "="
              _ -> binary
            end

          Base.decode64(binary)
        catch
          _, _ ->
            :error
        end
    end
  end

  def safe_binary_to_term!(binary, opts \\ []) do
    case safe_binary_to_term(binary, opts) do
      {:ok, term} ->
        term

      :error ->
        raise ArgumentError, "unsafe terms"
    end
  end

  def safe_binary_to_term(binary, opts \\ [])

  def safe_binary_to_term(binary, opts) when is_binary(binary) do
    term = :erlang.binary_to_term(binary, opts)
    safe_terms(term)
    {:ok, term}
  catch
    :throw, :safe_terms ->
      :error
  end

  defp safe_terms(list) when is_list(list) do
    safe_list(list)
  end

  defp safe_terms(tuple) when is_tuple(tuple) do
    safe_tuple(tuple, tuple_size(tuple))
  end

  defp safe_terms(map) when is_map(map) do
    fun = fn key, value, acc ->
      safe_terms(key)
      safe_terms(value)
      acc
    end

    :maps.fold(fun, map, map)
  end

  defp safe_terms(other)
       when is_atom(other) or is_number(other) or is_bitstring(other) or is_pid(other) or
              is_reference(other) do
    other
  end

  defp safe_terms(_other) do
    throw(:safe_terms)
  end

  defp safe_list([]), do: :ok

  defp safe_list([h | t]) when is_list(t) do
    safe_terms(h)
    safe_list(t)
  end

  defp safe_list([h | t]) do
    safe_terms(h)
    safe_terms(t)
  end

  defp safe_tuple(_tuple, 0), do: :ok

  defp safe_tuple(tuple, n) do
    safe_terms(:erlang.element(n, tuple))
    safe_tuple(tuple, n - 1)
  end

  defp urlsafe_encode64(<<?+, rest::binary>>, acc) do
    urlsafe_encode64(rest, <<acc::binary, ?->>)
  end

  defp urlsafe_encode64(<<?/, rest::binary>>, acc) do
    urlsafe_encode64(rest, <<acc::binary, ?_>>)
  end

  defp urlsafe_encode64(<<?=, rest::binary>>, acc) do
    urlsafe_encode64(rest, acc)
  end

  defp urlsafe_encode64(<<c, rest::binary>>, acc) do
    urlsafe_encode64(rest, <<acc::binary, c>>)
  end

  defp urlsafe_encode64(<<>>, acc) do
    acc
  end

  defp urlsafe_decode64(<<?-, rest::binary>>, acc) do
    urlsafe_decode64(rest, <<acc::binary, ?+>>)
  end

  defp urlsafe_decode64(<<?_, rest::binary>>, acc) do
    urlsafe_decode64(rest, <<acc::binary, ?/>>)
  end

  defp urlsafe_decode64(<<c, rest::binary>>, acc) do
    urlsafe_decode64(rest, <<acc::binary, c>>)
  end

  defp urlsafe_decode64(<<>>, acc) do
    acc
  end
end
