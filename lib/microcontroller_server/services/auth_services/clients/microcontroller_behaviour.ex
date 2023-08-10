defmodule MicrocourlntrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour do
  alias HTTPoison.{Request, Error}

  @moduledoc """
  Behaviour for the API requests for the microcontroller auth server. It's written this way
  to be able to be mocked.
  """

  @doc """
  Wrapper for HTTPoison get. It's written this way to be able to be mocked in tests.
  """
  @callback get(String.t()) :: {:ok, Request.t()} | {:error, Error.t()}
end
