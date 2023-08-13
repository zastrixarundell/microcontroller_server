defmodule MicrocontrollerServer.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :user_id, :integer
      add :location_id, :integer

      timestamps()
    end

    create index(:devices, [:location_id])
  end
end
