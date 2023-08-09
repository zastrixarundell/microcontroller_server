Mox.defmock(MicrocontrollerAuthMock, for: MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthBehaviour)
Application.put_env(:microcontroller_server, :microcontroller_auth_server, MicrocontrollerAuthMock)

Mox.defmock(AuthServiceMicrocontrollerMock, for: MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour)
Application.put_env(:microcontroller_server, :microcontroller_auth_client, AuthServiceMicrocontrollerMock)


ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MicrocontrollerServer.Repo, :manual)
