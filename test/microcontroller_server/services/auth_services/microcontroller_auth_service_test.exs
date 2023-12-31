defmodule MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthServiceTest do
  use ExUnit.Case

  import Mox

  alias HTTPoison.{Error, Response}

  doctest MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthService, import: true

  setup do
    expect(AuthServiceMicrocontrollerMock, :get, fn _path, body_params ->
      case body_params.token do
        "INVALID_TOKEN" ->
          {
            :ok,
            %Response{
              status_code: 401
            }
          }
        "INACCESSIBLE_SERVER" ->
        {
          :error,
          %Error{}
        }
        _ ->
        {
          :ok,
          %Response{
            status_code: 200,
            body: %{user_id: 1, location_id: 2, controller_id: 3} |> Jason.encode!()
          }
        }
      end
    end)

    :ok
  end
end
