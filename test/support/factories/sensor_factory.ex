defmodule MicrocontrollerServer.Factories.SensorFactory do
  # Stateless factory for now.

  # use ExMachina, repo: MicrocontrollerServer.Repo

  use ExMachina


  def sensor_factory(options \\ []) do
    %MicrocontrollerFactory.Sensor{
      id: sequence(:sensor_id),
      name: Keyword.get(options, :sensor_name, sequence(:sensor_name, &"Sensor #{&1}")),
      microcontroller: Keyword.get(options, :microcontroller, build(:microcontroller))
    }
  end
end
