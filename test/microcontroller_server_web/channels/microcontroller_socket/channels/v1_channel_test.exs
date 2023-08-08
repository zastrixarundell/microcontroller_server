defmodule MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1ChannelTest do
  use MicrocontrollerServerWeb.ChannelCase

  # TODO: Add factory for microcontrollers and initial readings.

  setup do
    {:ok, _, socket} =
      MicrocontrollerServerWeb.MicrocontrollerSocket
      |> socket()
      |> subscribe_and_join(
        MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1,
        "microcontroller:v1:#{System.unique_integer([:positive])}",
        %{api_token: 123}
      )

    %{socket: socket}
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
