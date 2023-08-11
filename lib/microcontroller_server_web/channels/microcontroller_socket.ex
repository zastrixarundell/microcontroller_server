defmodule MicrocontrollerServerWeb.MicrocontrollerSocket do
  use Phoenix.Socket

  @moduledoc """
  Socket for microcontrollers trying to authenticate to the server. This file handles the incoming
  connections, checks whether the API token which they are sending are valid and in case they are
  it allows the request to be handled by the correct API version of the channel.
  """

  channel "microcontroller:v1:*", MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1

  alias MicrocontrollerServer.{Microcontroller, Services.AuthServices}

  require Logger

  @impl true
  def connect(_params, socket, connect_info) do
    token =
      connect_info
      |> Map.get(:x_headers, [])
      |> Enum.find_value(&extract_api_key/1)

    Logger.info("Receiving connection request for token: #{token}")

    with {:ok, token} <- api_token_regex(token),
         {:ok, user_id, location_id, controller_id} <- authenticate_token(token),
         {:ok, device} <- Microcontroller.get_device_by_fields(controller_id, user_id, location_id) do

      {:ok, assign(socket, device: device)}
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
  def id(socket), do: "microcontroller_socket:#{socket.assigns.device.location_id}"
end
