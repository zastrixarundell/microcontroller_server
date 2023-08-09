defmodule MicrocontrollerServerWeb.MicrocontrollerSocketTest do
  use MicrocontrollerServerWeb.ChannelCase, async: true

  doctest MicrocontrollerServerWeb.MicrocontrollerSocket, import: true

  alias MicrocontrollerServerWeb.MicrocontrollerSocket, as: Socket

  describe "The microcontroller" do
    test "connects to socket when the API token is valid" do
      {:ok, _socket} = connect(Socket, %{api_token: "API_TOKEN_MC_VZGkp2vvJJjHj3qZ"})
    end

    test "does not connect to the socket if the API token format is invalid" do
      {:error, "The token is missing or format is invalid."} = connect(Socket, %{api_token: "1"})
    end
  end

end
