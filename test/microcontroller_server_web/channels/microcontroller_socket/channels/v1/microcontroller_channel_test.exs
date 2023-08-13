defmodule MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1.MicrocontrollerChannelTest do
  use MicrocontrollerServerWeb.ChannelCase

  alias MicrocontrollerServerWeb.MicrocontrollerSocket, as: Socket

  alias MicrocontrollerServer.Microcontroller, as: Database

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

    {:ok, _, socket} =
      Socket
      |> connect(%{}, connect_info: %{x_headers: [{"x-api-key", "API_TOKEN_MC_VZGkp2vvJJjHj3qZ"}]})
      |> elem(1)
      |> subscribe_and_join(
        MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1.MicrocontrollerChannel,
        "microcontroller:v1:#{System.unique_integer([:positive])}"
      )

    %{socket: socket}
  end

  test "sending readings stores it in the database", %{socket: socket} do
    readings =
      0..5
      |> Enum.map(fn _ -> build(:reading) end)
      |> Enum.reduce(%{}, fn reading, acc ->
            acc
            |> Map.put(
                reading.sensor.name,
                reading
                  |> Map.take([:type, :value])
                  |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
                  |> List.wrap()
              )
          end
        )

    ref = push(socket, "upload_readings", readings)

    assert_reply ref, :ok

    refute Enum.empty?(Database.list_readings())
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to v1:lobby", %{socket: socket} do
    push(socket, "shout", %{"hello" => "all"})
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
