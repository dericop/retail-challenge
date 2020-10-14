defmodule RetailChallenge.UseCase.ErrorsHandler do
  alias RetailChallenge.Model.ErrorModel
  require Logger
  @moduledoc false

  @default_error "Internal Server Error"
  @error_status 500

  def handle_error({:error, :not_found}) do
    ErrorModel.new("sku not found")
    |> handle_error(404)
  end

  def handle_error({:error, :invalid_request}) do
    ErrorModel.new("Bad Request")
    |> handle_error(400)
  end

  def handle_error({:error, :stock_not_available}) do
    ErrorModel.new("stock not available")
    |> handle_error(409)
  end

  def handle_error({:error, :media_type_not_supported}) do
    ErrorModel.new("Unsupported Media Type")
    |> handle_error(415)
  end

  def handle_error({:error, :invalid_credentials}) do
    ErrorModel.new("Unauthorized")
    |> handle_error(401)
  end

  def handle_error(error) do
    Logger.warn "Unexpected error #{inspect(error)}"
    default_error()
  end

  def handle_error(%ErrorModel{} = error, status) do
    Logger.warn "Handling error #{inspect(error)}"
    case Poison.encode(error) do
      {:ok, json} -> %{status: status, body: json}
      error -> Logger.warn "Error generating ciphered error response #{inspect(error)}"
               default_error()
    end
  end

  defp default_error() do
    {:ok, body} = ErrorModel.new(@default_error)
                  |> Poison.encode()
    %{status: @error_status, body: body}
  end

end
