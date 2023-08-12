defmodule MicrocontrollerServerWeb.MicrocontrollerSocketTest do
  use MicrocontrollerServerWeb.ChannelCase, async: true

  doctest MicrocontrollerServerWeb.MicrocontrollerSocket, import: true

  alias MicrocontrollerServerWeb.MicrocontrollerSocket, as: Socket
  alias MicrocontrollerServer.Microcontroller.Device

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

      assert socket.id == "microcontroller:3"

      assert %{device: %Device{} = device} == socket.assigns

      received_message = assert_receive {:socket_push, :text, _}

      assert {:ok, message} = Jason.decode(received_message |> elem(2), keys: :atoms)

      assert device.controller_id == message.payload.controller_id
      assert device.user_id == message.payload.user_id
      assert device.location_id == message.payload.location_id
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
