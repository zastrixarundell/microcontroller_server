defmodule MicrocontrollerServer.Microcontroller.Sensor do
  @moduledoc """
  Module representing the Sensor model.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias MicrocontrollerServer.Microcontroller.{Device, Reading}

  schema "sensors" do
    field :name, :string
    belongs_to :device, Device
    has_many :readings, Reading

    timestamps()
  end

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
