defmodule MicrocontrollerServer.Factories.MicrocontrollerFactory do
  # Stateless factory for now.

  # use ExMachina, repo: MicrocontrollerServer.Repo

  use ExMachina


  def microcontroller_factory(options \\ []) do
    %MicrocontrollerFactory.Microcontroller{
      id: sequence(:controller_id),
      user_id: Keyword.get(options, :user_id, sequence(:user_id)),
      location_id: Keyword.get(options, :location_id, sequence(:location_id))
    }
  end
end
