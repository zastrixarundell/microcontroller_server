defmodule MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthService do
  @behaviour MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthBehaviour

  alias HTTPoison.Response

  @doc """
  Authenticate the token against the authentication servers. If the token is okay
  then the authentication server witll give basic controller infromation
  like the controller id, user id and location id (the location ID is used)
  to send information to the controlers en-masse.

  ### Examples

      iex> authenticate_token("CORRECT_TOKEN")
      {:ok, %{user_id: 1, location_id: 2, controller_id: 3}}

      iex> authenticate_token("INVALID_TOKEN")
      {:error, :authentication_failed}
  """
  def authenticate_token(token) do
    body_params = %{
      token: token
    }

    requet_url =
      auth_server_details()
      |> Keyword.get(:server)
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(body_params))
      |> URI.to_string()

    with {:ok, %Response{status_code: 200} = response} <- auth_client().get(requet_url),
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

  defp auth_server_details() do
    Application.get_env(:microcontroller_server, MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthService, %{})
  end

  defp auth_client() do
    Application.get_env(:microcontroller_server, :microcontroller_auth_client, MicrocontrollerServer.Services.AuthServices.Clients.MicrocontrollerClient)
  end
end
