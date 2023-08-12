defmodule MicrocontrollerServerWeb.MicrocontrollerSocket do
  use Phoenix.Socket

  @moduledoc """
  Socket for microcontrollers trying to authenticate to the server. This file handles the incoming
  connections, checks whether the API token which they are sending are valid and in case they are
  it allows the request to be handled by the correct API version of the channel.

  When the client connects to the socket a message is sent to it containing the required metadata.
  """

  channel "microcontroller:v1:*", MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1

  alias MicrocontrollerServer.{Microcontroller, Microcontroller.Device, Services.AuthServices}

  require Logger

  # Overriding the default behaviour for websockets to send metadata.

  defoverridable init: 1

  @impl true
  def init(state) do
    response = {:ok, {_, %{transport_pid: transport_pid} = socket}} = super(state)

    case generate_metadata_message(socket) do
      {:ok, message} ->
        send(transport_pid, {:socket_push, :text, message})
        Logger.debug("Sent metadata to μController: #{socket.assigns.device.controller_id}")

      _ ->
        Logger.warning("Failed to send metadata to μController: #{socket.assigns.device.controller_id}")
    end

    response
  end

  defoverridable terminate: 2

  @impl true
  def terminate(_reason, {_, socket}) do
    Logger.debug("Socket for μController #{socket.assigns.device.controller_id} has closed. Cleaning up.")
    :ok
  end

  @impl true
  def connect(_params, socket, connect_info) do
    token =
      connect_info
      |> Map.get(:x_headers, [])
      |> Enum.find_value(&extract_api_key/1)

    Logger.info("Receiving μController connection request for token: '#{token}'")

    with {:ok, token} <- api_token_regex(token),
         {:ok, user_id, location_id, controller_id} <- authenticate_token(token),
         {:ok, device} <- Microcontroller.get_device_by_fields(controller_id, user_id, location_id) do

      Logger.info("μController connection accepted.")

      {:ok, assign(socket, :device, device)}
    else
      {:error, :invalid_token} ->
        Logger.info("Token '#{token}' failed the Regex check.")
        {:error, "The token is missing or format is invalid."}

      {:error, :failed_authentication} ->
        Logger.info("Token '#{token}' is invalid according to the auth server.")
        {:error, "The token is invalid. Please renew your subscription."}
    end
  end

  @doc """
  Generate the metadata message for sockets. This is a message which gives the socket
  basic information about itself to be used in future API calls.

  ## Examples

      iex> generate_metadata_message(%Phoenix.Socket{assigns: %{device: %MicrocontrollerServer.Microcontroller.Device{location_id: 1, user_id: 2, controller_id: 3}}})
      {:ok, ~S({"ref":null,"payload":{"controller_id":3,"user_id":2,"location_id":1},"topic":null,"join_ref":null,"event":"phx_reply"})}

      iex> generate_metadata_message(%Phoenix.Socket{})
      :error
  """
  @spec generate_metadata_message(socket :: Phoenix.Socket.t()) :: {:ok, String.t()} | :error
  def generate_metadata_message(%Phoenix.Socket{} = socket) do
    with {:ok, assigns} <- Map.fetch(socket, :assigns),
         {:ok, %Device{} = device} <- Map.fetch(assigns, :device),
         {:ok, message} <- generate_metadata_string(socket, device) do
          {:ok, message}
    else
      _ ->
        :error
    end

  end

  defp generate_metadata_string(%Phoenix.Socket{} = socket, %Device{} = device) do
    %{
      topic: socket.id,
      ref: socket.ref,
      join_ref: socket.join_ref,
      event: "phx_reply",
      payload: %{
        user_id: device.user_id,
        controller_id: device.controller_id,
        location_id: device.location_id
      }
    }
    |> Jason.encode()
  end

  @doc """
  Retrieve the `x-api-key` header from a list of x_headers. These headers are present in
  the `connect_info` variable in the connect/3 function call.

  ## Examples

      iex> extract_api_key({"x-api-key", "API_TOKEN_MC_VZGkp2vvJJjHj3qZ"})
      "API_TOKEN_MC_VZGkp2vvJJjHj3qZ"

      iex> extract_api_key({"x-api-key1", "API_TOKEN_MC_VZGkp2vvJJjHj3qZ"})
      nil
  """
  @spec extract_api_key(any() | {String.t(), String.t()}) :: String.t() | nil
  def extract_api_key({"x-api-key", key}) when is_binary(key), do: key
  def extract_api_key(_), do: nil

  @doc """
  Check the API token against a preset regex rule. The rule is that the API token
  must start with `API_TOKEN_MC_` and is then followed by at least `16` characters
  which can be uppercase and lowercaser letters alongside numbers.

  ## Examples

      iex> api_token_regex("API_TOKEN_MC_VZGkp2vvJJjHj3qZ")
      {:ok, "API_TOKEN_MC_VZGkp2vvJJjHj3qZ"}

      iex> api_token_regex("API_TOKEN_MC_VZGkp2vvJ")
      {:error, :invalid_token}

      iex> api_token_regex("oAPI_TOKEN_MC_VZGkp2vvJ")
      {:error, :invalid_token}

      iex> api_token_regex("oAPI_TOKEN_MC_VZGkp2vvJ@")
      {:error, :invalid_token}

      iex> api_token_regex("API_TOKEN_MC_VZGkp2vvJJjHj3q@")
      {:error, :invalid_token}

      iex> api_token_regex(nil)
      {:error, :invalid_token}
  """
  @spec api_token_regex(api_token :: String.t()) :: {:error, :invalid_token} | {:ok, String.t()}
  def api_token_regex(nil), do: {:error, :invalid_token}

  def api_token_regex(api_token) do
    case String.match?(api_token, ~r/^API_TOKEN_MC_[a-zA-Z0-9]{16,}$/) do
      true ->
        {:ok, api_token}
      false ->
        {:error, :invalid_token}
    end
  end

  @doc """
  Authenticate the device with the microcontroller authentication server.

  The function returns the following if successful:

  * `:ok`
  * `user_id`
  * `location_id`
  * `controller_id`

  ## Examples

      iex> authenticate_token("API_TOKEN_MC_VZGkp2vvJJjHj3qZ")
      {:ok, 1, 2, 3}

      iex> authenticate_token("API_TOKEN_MC_INVALIDTOKENTEST")
      {:error, :failed_authentication}
  """
  @spec authenticate_token(any) :: {:ok, integer(), integer(), integer()} | {:error, :failed_authentication}
  def authenticate_token(api_token) do
    case authentication_service().authenticate_token(api_token) do
      {:ok, data} ->
        {:ok, data.user_id, data.location_id, data.controller_id}
      {:error, _} ->
        {:error, :failed_authentication}
    end
  end

  defp authentication_service do
    Application.get_env(:microcontroller_server, :microcontroller_auth_server, AuthServices.MicrocontrollerAuthService)
  end

  # Join the unique channel only for the select location. All of the clients will get the message
  # and they will need a unique identifier logic on their side but this is okay in the instance of
  # wanting to turn off all of the lights or similar.
  @impl true
  def id(socket), do: "microcontroller:#{socket.assigns.device.controller_id}"
end
