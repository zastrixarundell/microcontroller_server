defmodule MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour do
  alias HTTPoison.{Request, Error}

  @callback get(path :: String.t(), body_params :: %{}) :: {:ok, %Request{}} | {:error, %Error{}}
end
