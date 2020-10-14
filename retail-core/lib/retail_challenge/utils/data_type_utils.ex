defmodule RetailChallenge.Utils.DataTypeUtils do
  require Logger

  def normalize(value = %{__struct__: _}), do: value

  def normalize(map = %{}) do
    Map.to_list(map)
    |> Enum.map(fn {key, value} -> {String.to_atom(key), normalize(value)} end)
    |> Enum.into(%{})
  end

  def normalize(value) when is_list(value), do: Enum.map(value, &normalize/1)
  def normalize(value), do: value

  def base64_decode(string) do
    {:ok, value} = Base.decode64(string, padding: false)
    value
  end

  def extract_header(headers, name) when is_list(headers) do
    case extract_header!(headers, name) do
      {:ok, value} when value != nil -> {:ok, value}
      _ -> {:error, :not_found}
    end
  end

  def extract_header(headers, name) do
    {:error, "headers is not a list when finding #{inspect(name)}: #{inspect(headers)}"}
  end

  def extract_header!(headers, name) when is_list(headers) do
    out = Enum.filter(headers, create_evaluator(name))
    case out do
      [{_, value} | _] -> {:ok, value}
      _ -> {:ok, nil}
    end
  end

  defp create_evaluator(name) do
    fn
      {^name, _} -> true
      _ -> false
    end
  end

  def format("true", "boolean"), do: true
  def format("false", "boolean"), do: false

  def format(value, "number") when is_binary(value) do
    {number, ""} = Float.parse(value)
    number
  rescue
    err -> Logger.warn "Error parsing #{value} to float #{inspect(err)}"
           nil
  end

  def format(value, _type), do: value

end
