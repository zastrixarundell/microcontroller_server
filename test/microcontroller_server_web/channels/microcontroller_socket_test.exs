defmodule MicrocontrollerServerWeb.MicrocontrollerSocketTest do
  use MicrocontrollerServerWeb.ChannelCase, async: true

  doctest MicrocontrollerServerWeb.MicrocontrollerSocket, import: true

  alias MicrocontrollerServerWeb.MicrocontrollerSocket, as: Socket

  import Mox

  setup do
    expect(MicrocontrollerAuthMock, :authenticate_token, fn token ->
      case token do
        "API_TOKEN_MC_INVALIDTOKENTEST" ->
          {:error, :authentication_failed}
        _ ->
          {:ok, %{user_id: 1, location_id: 2, controller_id: 3}}
      end
    end)

    :ok
  end

  describe "The microcontroller" do
    test "connects to socket when the API token is valid" do
      {:ok, _socket} = connect(Socket, %{token: "API_TOKEN_MC_VZGkp2vvJJjHj3qZ"})
    end

    test "does not connect to the socket if the API token format is invalid" do
      {:error, "The token is missing or format is invalid."} = connect(Socket, %{api_token: "1"})
    end

    test "does not connect to the socket if the API token is invalid" do
      error_message = "The token is invalid. Please renew your subscription."

      {:error, ^error_message} = connect(Socket, %{token: "API_TOKEN_MC_INVALIDTOKENTEST"})
    end
  end

end
