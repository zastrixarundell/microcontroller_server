defmodule MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour do
  alias HTTPoison.{Request, Error}

  @callback get(String.t()) :: {:ok, %Request{}} | {:error, %Error{}}
end
