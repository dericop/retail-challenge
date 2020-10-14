defmodule RetailChallenge.Entrypoint.Rest.RestController do
  alias RetailChallenge.Utils.DataTypeUtils
  alias RetailChallenge.EntryPoint.Rest.HealthIndicator
  alias RetailChallenge.UseCase.OrderUseCase
  alias RetailChallenge.UseCase.AuthenticationUseCase  

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
    DataTypeUtils.normalize(conn.body_params)
    |> validate_headers(conn.req_headers)
    |> OrderUseCase.handle_order_request
    |> build_empty_response(conn)
  end

  def validate_headers(body, headers) do
    with {:ok, _} <- validate_content_type(headers),
    {:ok, user} <- validate_session(headers)
    
    do
      {user, body}
      else
        error -> error
    end

  end

  def validate_session(headers) do 
    DataTypeUtils.extract_header(headers, "authorization") 
    |> AuthenticationUseCase.validate_session
  end

  def validate_content_type(headers) do
    case DataTypeUtils.extract_header(headers, "content-type") do
      {:ok, "application/json"} -> {:ok, true}
      error -> {:error, :media_type_not_supported}
    end
  
  end

  def build_empty_response(_, conn) do
    build_response(%{status: 204, body: ""}, conn)
  end

  def build_response(%{cookie: {key, value}}, conn) do
    conn
    |> put_resp_cookie(key, value, path: "/", http_only: true, secure: true, same_site: "Strict")
    |> send_resp(200, "")
  end

  def build_response(%{status: status, body: body}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  def build_response(response, conn) do
    build_response(%{status: 200, body: response}, conn)
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
