defmodule MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthService do
  @behaviour MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthBehaviour

  @moduledoc """
  Service file for perfoming requests to the microcontroller authentication server.
  """

  alias HTTPoison.Response

  @doc """
  Authenticate the token against the authentication servers. If the token is okay
  then the authentication server witll give basic controller infromation
  like the Controller ID, user ID and location ID (the location ID is used
  to send information to the controlers en-masse).

  ### Examples

      iex> authenticate_token("CORRECT_TOKEN")
      {:ok, %{user_id: 1, location_id: 2, controller_id: 3}}

      iex> authenticate_token("INVALID_TOKEN")
      {:error, :authentication_failed}
  """
  @spec authenticate_token(token :: binary()) :: {:ok, %{user_id: integer(), location_id: integer(), contrroller_id: integer()}} | {:error, :authentication_failed}
  def authenticate_token(token) do
    with {:ok, %Response{status_code: 200} = response} <- auth_client().get("/api/v1/auth", %{token: token}),
         {:ok, %{"user_id" => uid, "location_id" => lid, "controller_id" => cid}} <- decode_body(response) do
      {:ok, %{user_id: uid, location_id: lid, controller_id: cid}}
    else
      _ ->
        {:error, :authentication_failed}
    end

  end

  defp decode_body(response) do
    response
    |> Map.get(:body, "{}")
    |> Jason.decode()
  end

  defp auth_client() do
    Application.get_env(:microcontroller_server, :microcontroller_auth_client, MicrocontrollerServer.Services.AuthServices.Clients.MicrocontrollerClient)
  end
end
