defmodule MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1.MicrocontrollerChannel do
  use MicrocontrollerServerWeb, :channel

  alias MicrocontrollerServer.Microcontroller, as: Database
  alias MicrocontrollerServer.Repo

  @moduledoc false

  require Logger

  @impl true
  def join("microcontroller:v1:" <> _mc_id, payload, socket) do
    Logger.debug("Payload during MC join on V1: #{inspect payload}")

    {:ok, socket}
  end

  @impl true
  def handle_in("upload_readings", payload, socket) do
    device = socket.assigns.device

    Repo.transaction(fn ->
        device_sensors = Database.list_sensors_for_device(device.id)

        missing_sensors =
          payload
          |> Map.keys()
          |> reject_sensor_names(device_sensors)
          |> Enum.map(fn sensor_name -> {:ok, _sensor} = Database.create_sensor(%{device_id: device.id, name: sensor_name}) end)
          |> Enum.map(&elem(&1, 1))

        all_sensors = device_sensors ++ missing_sensors

        payload
        |> Enum.map(fn {sensor_name, values} -> insert_sensor_name(values, get_sensor_id(all_sensors, sensor_name)) end)
        |> List.flatten()
        |> Database.create_readings
      end
    )

    {:reply, :ok, socket}
  end

  defp insert_sensor_name(readings, sensor_id) do
    readings
    |> Enum.map(&Map.put(&1, "sensor_id", sensor_id))
  end

  defp reject_sensor_names(names, device_sensors) do
    names
    |> Enum.reject(&Enum.any?(device_sensors, fn actual_sensor -> actual_sensor.name == &1 end))
  end

  defp get_sensor_id(sensors, sensor_name) do
    sensor =
      sensors
      |> Enum.find(fn sensor -> sensor.name == sensor_name end)

    sensor.id
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (v1:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
