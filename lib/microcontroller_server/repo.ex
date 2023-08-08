defmodule MicrocontrollerServer.Repo do
  use Ecto.Repo,
    otp_app: :microcontroller_server,
    adapter: Ecto.Adapters.Postgres
end
