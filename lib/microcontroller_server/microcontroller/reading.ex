defmodule MicrocontrollerServer.Microcontroller.Reading do
  @moduledoc """
  Module representing the Reading model.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "readings" do
    field :type, MicrocontrollerServer.Microcontroller.ReadingType
    field :value, :float
    belongs_to :sensor, MicrocontrollerServer.Microcontroller.Sensor

    timestamps()
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:type, :value])
    |> validate_required([:type, :value])
  end
end
