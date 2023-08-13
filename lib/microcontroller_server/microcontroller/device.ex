defmodule MicrocontrollerServer.Microcontroller.Device do
  @moduledoc """
  Module representing the Device model.
  """

  alias MicrocontrollerServer.Microcontroller.{Reading, Sensor}

  @type t :: %__MODULE__{
          id: integer,
          user_id: integer,
          location_id: integer,
          controller_id: integer,
          sensors: list(Sensor.t()),
          readings: list(Reading.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

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
