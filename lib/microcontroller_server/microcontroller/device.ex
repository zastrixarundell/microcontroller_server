defmodule MicrocontrollerServer.Microcontroller.Device do
  use Ecto.Schema
  import Ecto.Changeset

  alias MicrocontrollerServer.Microcontroller.Sensor

  schema "devices" do
    field :user_id, :integer
    field :location_id, :integer
    field :controller_id, :integer

    has_many :sensors, Sensor
    has_many :readings, through: [:sensors, :readings]

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:user_id, :location_id, :controller_id])
    |> validate_required([:user_id, :location_id, :controller_id])
    |> unique_constraint(:controller_id)
  end
end
