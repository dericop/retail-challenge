defmodule Perf.ConnectionProcess do
  use GenServer

  require Logger

  defstruct [:conn, :params, request: %{}]

  def start_link({scheme, host, port, id}) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {scheme, host, port}, name: id)
    send(pid, :late_init)
    {:ok, pid}
  end

  def request(pid, method, path, headers, body) do
    :timer.tc(
      fn ->
        GenServer.call(pid, {:request, method, path, headers, body}, 15_000)
      end
    )
  end

  ## Callbacks

  @impl true
  def init({scheme, host, port}) do
    state = %__MODULE__{conn: nil, params: {scheme, host, port}}
    {:ok, state}
  end

  @impl true
  def handle_info(:late_init, state = %__MODULE__{params: {scheme, host, port}}) do
    case Mint.HTTP.connect(scheme, host, port, options(scheme)) do
      {:ok, conn} -> {:noreply, %{state | conn: conn}}
      {:error, err} ->
        Logger.warn("Error creating connection with #{inspect({scheme, host, port})}: #{inspect(err)}")
        {:noreply, state}
    end
  end

  @compile {:inline, options: 1}
  defp options(:https) do
    [
      transport_opts: [
        verify: :verify_none
      ]
    ]
  end

  defp options(:http) do
    []
  end

  @impl true
  def handle_call({:request, _, _, _, _}, _, state = %__MODULE__{conn: nil}) do
    send(self(), :late_init)
    Process.sleep(200)
    {:reply, {:nil_conn, "Invalid connection state: nil"}, state}
  end

  @impl true
  def handle_call({:request, method, path, headers, body}, from, state) do
    init_time = :erlang.monotonic_time(:micro_seconds)
    #IO.puts "Making Request!"
    body = get_body(body)
    case Mint.HTTP.request(state.conn, method, path, headers, body) do
      {:ok, conn, request_ref} ->
        state = %{
          state |
          conn: conn,
          request: %{
            from: from,
            response: %{},
            ref: request_ref,
            status: nil,
            init: init_time
          }
        }
        {:noreply, state}

      {:error, conn, reason} ->
        state = put_in(state.conn, conn)
        send(self(), :late_init)
        {:reply, {:error_conn, reason}, state}
    end
  end

  defp get_body(_body) do
    val = Enum.random(
      [
        "00d6dde5-e23c-4b0b-91fc-d5500ef6b517",
        "0255597e-2c57-4e0f-9c31-be7bf53e7f0f",
        "03dbd3d1-34e8-43f7-99bd-729ad4613250",
        "0a7d5687-9890-47b0-9f50-93308bdf696f",
        "0c2b5c74-aafd-4539-98b6-b3e60972643c",
        "0f577c7c-a70e-4d0b-95b4-b62b913599af",
        "10b3a826-2b75-404a-b266-c2948f306aab",
        "149a02cf-7e58-4554-850c-92ff7d1e10d9",
        "171b9a99-221c-418d-af21-62b9e171a617",
        "176fd606-f275-42d6-ab5b-4d74c8d334e4"
      ]
    )
    "{\"sku\":\"" <> val <> "\",\"units\":1}"
  end

  @impl true
  def handle_info(message, state = %__MODULE__{conn: nil}) do
    Logger.warn(fn -> "Received message with null conn: " <> inspect(message) end)
    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        Logger.warn(fn -> "Received unknown message: " <> inspect(message) end)
        {:noreply, state}

      {:ok, conn, []} -> {:noreply, put_in(state.conn, conn)}

      {:ok, conn, responses} ->
        state = put_in(state.conn, conn)
        state = Enum.reduce(responses, state, process_response_fn(state))
        {:noreply, state}

      {:error, conn, reason, responses} ->
        #IO.puts("########ERROR########")
        #IO.inspect(reason)
        case state.request do
          %{from: from, ref: request_ref} -> GenServer.reply(from, {:protocol_error, reason})
          _ -> nil
        end
        {:noreply, put_in(state.conn, nil)}
    end
  end

  defp process_response_fn(
         %__MODULE__{
           request: %{
             ref: original_ref
           }
         }
       ) do
    fn (message, state) ->
      case message do
        {:status, ^original_ref, status} -> put_in(state.request.status, status)
        {:done, ^original_ref} -> process_response(message, state)
        {:error, ^original_ref, reason} -> process_response(message, state)
        _ -> state
      end
    end
  end


  defp process_response(
         {:done, _request_ref},
         state = %__MODULE__{
           request: %{
             from: from,
             init: init,
             status: status
           }
         }
       ) do
    #IO.puts("Done request!")
    GenServer.reply(from, {status_for(status), :erlang.monotonic_time(:micro_seconds) - init})
    %{state | request: %{}}
  end

  defp process_response(
         {:error, _request_ref, reason},
         state = %__MODULE__{
           request: %{
             from: from,
             init: init
           }
         }
       ) do
    GenServer.reply(from, {:protocol_error, reason})
    #IO.puts("Request error")
    IO.inspect(reason)
    %{state | request: %{}}
  end

  defp status_for(status) when status >= 200 and status < 400, do: :ok
  defp status_for(status), do: {:fail_http, status}


end

