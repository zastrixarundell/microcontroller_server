defmodule MicrocontrollerServer.Repo.Migrations.AddControllerIdToDevices do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :controller_id, :integer, null: false
    end

    create unique_index(:devices, :controller_id)
  end
end
