defmodule MicrocontrollerServer.Microcontroller.Sensor do
  @moduledoc """
  Module representing the Sensor model.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias MicrocontrollerServer.Microcontroller.{Device, Reading}

  @type t :: %__MODULE__{
    id: integer,
    name: String.t(),
    device: Device.t(),
    readings: list(Reading.t()),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  schema "sensors" do
    field :name, :string
    belongs_to :device, Device
    has_many :readings, Reading

    timestamps()
  end

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, [:name, :device_id])
    |> validate_required([:name, :device_id])
  end
end
