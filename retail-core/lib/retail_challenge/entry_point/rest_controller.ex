defmodule RetailChallenge.Entrypoint.Rest.RestController do
  alias RetailChallenge.Utils.DataTypeUtils
  alias RetailChallenge.EntryPoint.Rest.HealthIndicator
  alias RetailChallenge.UseCase.{OrderUseCase, AuthenticationUseCase, ErrorsHandler}

  require Logger
  use Plug.Router

  plug Plug.Logger, log: :debug
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Poison
  plug :dispatch

  get "/health" do
    HealthIndicator.health()
    |> build_response(conn)
  end

  post "/order" do
    with {:ok, _} <- validate_content_type(conn.req_headers),
         {:ok, user} <- validate_token(conn.req_headers) do
      DataTypeUtils.normalize(conn.body_params)
      |> OrderUseCase.handle_order_request(user)
      |> build_response(conn)
    else
      error ->
        ErrorsHandler.handle_error(error)
        |> build_response(conn)
    end
  end

  defp validate_token(headers) do
    case DataTypeUtils.extract_header(headers, "authorization") do
      {:ok, token} -> AuthenticationUseCase.validate_session(token)
      error -> {:error, :invalid_credentials}
    end
  end

  defp validate_content_type(headers) do
    case DataTypeUtils.extract_header(headers, "content-type") do
      {:ok, "application/json"} -> {:ok, true}
      _error -> {:error, :media_type_not_supported}
    end

  end

  def build_empty_response(_, conn) do
    build_response(%{status: 204, body: ""}, conn)
  end

  def build_response(%{status: status, body: body}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  def build_response(response, conn) do
    build_response(%{status: 200, body: Poison.encode!(response)}, conn)
  end

  match _ do
    conn
    |> handle_not_found(Logger.level())
  end

  defp handle_not_found(conn, :debug) do
    %{request_path: path} = conn
    body = Poison.encode!(%{status: 404, path: path})
    send_resp(conn, 404, body)
  end
  defp handle_not_found(conn, _level) do
    send_resp(conn, 404, "")
  end

end
