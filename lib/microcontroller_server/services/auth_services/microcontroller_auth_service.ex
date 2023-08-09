defmodule MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthService do
  @behaviour MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthBehaviour

  def authenticate_token("API_TOKEN_MC_INVALIDTOKENTEST") do

    # This should, in all actuality, check the response code of
    # the request and then decide whether the result should be ok or not.

    {:error, :authentication_failed}
  end

  def authenticate_token(_) do
    {:ok, %{user_id: 1, location_id: 2, controller_id: 3}}
  end
end
