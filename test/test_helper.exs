Mox.defmock(MicrocontrollerAuthMock, for: MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthBehaviour)
Application.put_env(:microcontroller_server, :microcontroller_auth_server, MicrocontrollerAuthMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MicrocontrollerServer.Repo, :manual)
