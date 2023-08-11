defmodule MicrocontrollerServer.Microcontroller.Reading do
  @moduledoc """
  Module representing the Reading model.
  """

  alias MicrocontrollerServer.Microcontroller.{ReadingType, Sensor}

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    id: integer(),
    type: ReadingType.t(),
    value: float(),
    sensor: Sensor.t()
  }

  schema "readings" do
    field :type, ReadingType
    field :value, :float
    belongs_to :sensor, Sensor

    timestamps()
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:type, :value, :sensor_id])
    |> validate_required([:type, :value, :sensor_id])
  end
end
