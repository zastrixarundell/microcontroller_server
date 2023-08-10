defmodule MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerClient do
  @behaviour MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour

  @moduledoc """
  Actual implementation of the HTTPoison request wrappers.
  """

  def get(uri), do: HTTPoison.get(uri)
end
