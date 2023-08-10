defmodule MicrocontrollerServer.Factories.ReadingsFactory do
  # Stateless factory for now.

  # use ExMachina, repo: MicrocontrollerServer.Repo

  use ExMachina


  def reading_factory(options \\ []) do
    type = Keyword.get(options, :type, sequence(:reading_type, ~W(temperature pressure illuminance humidity)))
    value = fetch_reading(options |> Keyword.get(:value), type)


    %MicrocontrollerServer.Reading{
      type: Keyword.get(options, :type, sequence(:reading_type, ~W(temperature pressure illuminance humidity))),
      value: value,
      sensor: build(:sensor)
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

  defp raw_reading(min, max) when is_integer(min) and is_integer(max) do
    :rand.uniform() * (max - min) + a
  end

  defp raw_reading(_, _), do: :error
end
