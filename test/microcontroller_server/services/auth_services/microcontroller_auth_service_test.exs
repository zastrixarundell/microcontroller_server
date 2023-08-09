defmodule MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthServiceTest do
  use ExUnit.Case

  import Mox

  alias HTTPoison.{Response, Error}

  doctest MicrocontrollerServer.Services.AuthServices.MicrocontrollerAuthService, import: true

  setup do
    expect(AuthServiceMicrocontrollerMock, :get, fn uri ->
      token =
        uri
        |> URI.parse()
        |> Map.get(:query)
        |> URI.decode_query()
        |> Map.get("token")

      case token do
        "INVALID_TOKEN" ->
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