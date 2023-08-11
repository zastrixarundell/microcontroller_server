defmodule MicrocontrollerServerWeb.MicrocontrollerSocket do
  use Phoenix.Socket

  @moduledoc """
  Socket for microcontrollers trying to authenticate to the server. This file handles the incoming
  connections, checks whether the API token which they are sending are valid and in case they are
  it allows the request to be handled by the correct API version of the channel.
  """

  channel "microcontroller:v1:*", MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1

  alias MicrocontrollerServer.Services.AuthServices

  require Logger

  @impl true
  def connect(params, socket, _connect_info) do
    potential_token = params |> Map.get("token")

    Logger.debug("Trying connection for API token: #{potential_token}")

    with {:ok, token} <- api_token_regex(potential_token),
         {:ok, user_id, location_id, controller_id} <- authenticate_token(token) do

      socket =
        socket
        |> assign(user_id: user_id)
        |> assign(location_id: location_id)
        |> assign(controller_id: controller_id)

      Logger.debug("Accepted connection for API token: #{potential_token} and for assigns: #{inspect(socket.assigns)}")

      {:ok, socket}
    else
      {:error, :invalid_token} ->
        Logger.debug("Token is invalid or missing.")
        {:error, "The token is missing or format is invalid."}

      {:error, :failed_authentication} ->
        Logger.debug("Token is invalid according to the AUTH server.")
        {:error, "The token is invalid. Please renew your subscription."}
    end
  end

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
  def id(socket), do: "microcontroller_socket:#{socket.assigns.location_id}"
end
