defmodule MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerClient do
  @behaviour MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour

  def get(uri), do: HTTPoison.get(uri)
end
