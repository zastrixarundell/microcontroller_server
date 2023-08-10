defmodule MicrocontrollerServer.Services.AuthServices.Clients.MicrocontrollerBehaviour do
  alias HTTPoison.{Request, Error}

  @moduledoc """
  Behaviour for the API requests for the microcontroller auth server. It's written this way
  to be able to be mocked.
  """

  @doc """
  Wrapper for HTTPoison get. It's written this way to be able to be mocked in tests.
  """
  @callback get(path :: String.t(), body_params :: %{}) :: {:ok, %Request{}} | {:error, %Error{}}
end
