defmodule MicrocontrollerServer.Factory do
  use ExMachina.Ecto, repo: MicrocontrollerServer.Repo

  alias MicrocontrollerServer.Microcontroller.{Device, Reading, Sensor}

  # Device

  def device_factory(options \\ %{}) do
    %Device{
      user_id: Map.get(options, :user_id, sequence(:user_id, &(&1), start_at: 1)),
      location_id: Map.get(options, :location_id, sequence(:location_id, &(&1), start_at: 1)),
      controller_id: Map.get(options, :controller_id, sequence(:controller_id, &(&1), start_at: 1))
    }
  end

  # Reading

  def reading_factory(options \\ %{}) do
    type = Map.get(options, :type, sequence(:reading_type, ~w(temperature pressure illuminance humidity)))

    value = fetch_reading(options |> Map.get(:value), type)

    %Reading{
      type: Map.get(options, :type, sequence(:reading_type, ~w(temperature pressure illuminance humidity))),
      value: value,
      sensor: Map.get(options, :sensor, build(:sensor, Map.take(options, [:device])))
    }
  end

  defp fetch_reading(nil, type) do
    case type do
      "temperature" ->
        raw_reading(0, 100)
      "pressure" ->
        raw_reading(0.5, 10)
      "illuminance" ->
        raw_reading(0, 108_000)
      "humidity" ->
        raw_reading(0, 100)
    end
  end

  defp fetch_reading(reading, _type), do: reading

  defp raw_reading(min, max) when is_number(min) and is_number(max) do
    :rand.uniform() * (max - min) + min
  end

  defp raw_reading(_, _), do: :error

  # Sensor

  def sensor_factory(options \\ %{}) do
    %Sensor{
      name: Map.get(options, :sensor_name, sequence(:sensor_name, &"Sensor #{&1}")),
      device: Map.get(options, :device, build(:device))
    }
  end
end
