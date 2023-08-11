defmodule MicrocontrollerServer.Microcontroller.ReadingType do
  @moduledoc """
  Data type to be used as a `MicrocontrollerServer.Microcontroller.Reading` field.
  This is used to that it can be written as a string in the model but to be saved
  as an integer in the database.
  """

  use Ecto.Type

  @map %{"temperature" => 0, "pressure" => 1, "illuminance" => 2, "humidity" => 3}

  @spec type :: :string
  def type, do: :string

  @spec cast(any) :: :error | {:ok, String.t()}
  def cast(string_key) when is_binary(string_key) do
    if Map.has_key?(@map, string_key) do
      {:ok, string_key}
    else
      :error
    end
  end

  def cast(int) when is_integer(int) do
    return = Enum.find(@map, fn {_k, v} -> v == int end) |> elem(0)
    if return do
      {:ok, return}
    else
      :error
    end
  end

  def cast(_), do: :error

  def load(value) when is_integer(value) do
    {:ok, Enum.find(@map, fn {_k, v} -> v == value end) |> elem(0)}
  end

  def load(value) when is_binary(value) do
    if Map.has_key?(@map, value) do
      {:ok, value}
    else
      :error
    end
  end

  @spec dump(any) :: :error | {:ok, integer()}
  def dump(string) when is_binary(string), do: Map.fetch(@map, string)

  def dump(value) when is_integer(value), do: {:ok, value}

  def dump(_) do
    :error
  end
end
