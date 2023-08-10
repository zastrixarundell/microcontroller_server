defmodule MicrocontrollerServer.Services.AuthServices.Clients.MicrocontrollerClient do
  @behaviour MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour

  def get(path, body_params) do
    auth_server_details()
    |> Keyword.get(:server)
    |> Kernel.<>(path)
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(body_params))
    |> URI.to_string()
    |> HTTPoison.get()
  end

  defp auth_server_details() do
    Application.get_env(:microcontroller_server, MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthService, %{})
  end
end
