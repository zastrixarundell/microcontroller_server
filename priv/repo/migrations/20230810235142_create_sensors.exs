defmodule MicrocontrollerServer.Repo.Migrations.CreateSensors do
  use Ecto.Migration

  def change do
    create table(:sensors) do
      add :name, :string
      add :device_id, references(:devices, on_delete: :delete_all)

      timestamps()
    end

    create index(:sensors, [:device_id])
  end
end
