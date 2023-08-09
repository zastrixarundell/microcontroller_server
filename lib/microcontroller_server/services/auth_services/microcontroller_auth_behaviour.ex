defmodule MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthBehaviour do
  @moduledoc """
  Behaviour module for the authorization server for microcontrollers
  """

  @callback authenticate_token(token :: String.t()) :: {:ok, %{}} | {:error, :authentication_failed}
end
