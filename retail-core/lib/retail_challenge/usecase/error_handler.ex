defmodule RetailChallenge.UseCase.ErrorsHandler do
  require Logger
  @moduledoc false

  @default_error "Internal server error"
  @error_status 500

  def handle_error({:error, :not_found}) do
    {404, %{orderstatus: "Rejected", Reason: "sku not found"}}
  end

  def handle_error({:error, :stock_not_available}) do
    {409, %{orderstatus: "Rejected", Reason: "stock not available"}}
  end

  def handle_error({:error, :invalid_credentials}, aes_data) do
    ErrorModel.new(401, "Invalid credentials")
    |> handle_error(aes_data)
  end

  def handle_error(%ErrorModel{status: status} = error, aes_data) do
    Logger.warn "Handling error #{inspect(error)}"
    with {:ok, json} <- build_error_response(error),
         {:ok, ciphered} <- encrypt_response(json, aes_data)
      do
      %{status: status, body: ciphered}
    else
      error -> Logger.warn "Error generating ciphered error response #{inspect(error)}"
               default_error()
    end
  end

  def handle_error(error, _aes_data) do
    Logger.warn "Unexpected error #{inspect(error)}"
    default_error()
  end

  defp build_error_response(%ErrorModel{} = error) do
    {:ok, Poison.encode!(%{errors: [error]})}
  end

  defp default_error() do
    {:ok, body} = ErrorModel.new(@error_status, @default_error)
                  |> build_error_response()
    %{status: @error_status, body: body}
  end

end
