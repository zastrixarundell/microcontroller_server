Mox.defmock(MicrocontrollerAuthMock, for: MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthBehaviour)
Application.put_env(:microcontroller_server, :microcontroller_auth_server, MicrocontrollerAuthMock)

Mox.defmock(AuthServiceMicrocontrollerMock, for: MicrocontrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour)
Application.put_env(:microcontroller_server, :microcontroller_auth_client, AuthServiceMicrocontrollerMock)

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MicrocontrollerServer.Repo, :manual)
