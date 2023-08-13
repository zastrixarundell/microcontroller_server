defmodule MicrocontrollerServer.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :type, :integer
      add :value, :float
      add :sensor_id, references(:sensors, on_delete: :delete_all)

      timestamps()
    end

    create index(:readings, [:sensor_id])
  end
end
