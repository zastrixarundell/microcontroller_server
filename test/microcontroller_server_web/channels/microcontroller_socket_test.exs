defmodule MicrocontrollerServerWeb.MicrocontrollerSocketTest do
  use MicrocontrollerServerWeb.ChannelCase, async: true

  doctest MicrocontrollerServerWeb.MicrocontrollerSocket, import: true

  alias MicrocontrollerServerWeb.MicrocontrollerSocket, as: Socket

  import MicrocontrollerServer.Factory
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
      device = insert(:device, user_id: 1, location_id: 2, controller_id: 3)

      {:ok, socket} = connect(Socket, %{}, connect_info: %{x_headers: [{"x-api-key", "API_TOKEN_MC_VZGkp2vvJJjHj3qZ"}]})

      assert socket.id == "microcontroller:location:3"

      assert %{device: device} == socket.assigns
    end

    test "does not connect to the socket if the API token format is invalid" do
      {:error, "The token is missing or format is invalid."} = connect(Socket, %{}, connect_info: %{x_headers: [{"x-api-key", "1"}]})
    end

    test "does not connect to the socket if the API token is invalid" do
      error_message = "The token is invalid. Please renew your subscription."

      {:error, ^error_message} = connect(Socket, %{}, connect_info: %{x_headers: [{"x-api-key", "API_TOKEN_MC_INVALIDTOKENTEST"}]})
    end
  end

end
