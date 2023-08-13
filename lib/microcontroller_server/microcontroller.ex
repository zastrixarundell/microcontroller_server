defmodule MicrocontrollerServer.Microcontroller do
  @moduledoc """
  The Microcontroller context.
  """

  import Ecto.Query, warn: false
  alias MicrocontrollerServer.Repo

  alias MicrocontrollerServer.Microcontroller.Device

  @doc """
  Returns the list of devices.

  ## Examples

      iex> list_devices()
      [%Device{}, ...]

  """
  def list_devices do
    Repo.all(Device)
  end

  @doc """
  Gets a single device.

  Raises `Ecto.NoResultsError` if the Device does not exist.

  ## Examples

      iex> get_device!(123)
      %Device{}

      iex> get_device!(456)
      ** (Ecto.NoResultsError)

  """
  def get_device!(id), do: Repo.get!(Device, id)

  @doc """
  Gets an existing device by controller_id.

  ## Examples

      iex> get_device_by_fields(1, 2, 3)
      {:ok, %Device{controller_id: 1, user_id: 2, location_id: 3}}

      iex> get_device_by_fields(bad_value, bad_value, bad_value)
      nil
  """
  def get_device_by_fields(controller_id, user_id, location_id) do
    case Repo.get_by(Device, controller_id: controller_id) do
      nil ->
        create_device(%{controller_id: controller_id, user_id: user_id, location_id: location_id})
      device ->
        {:ok, device}
    end
  end

  @doc """
  Creates a device.

  ## Examples

      iex> create_device(%{field: value})
      {:ok, %Device{}}

      iex> create_device(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_device(attrs \\ %{}) do
    %Device{}
    |> Device.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a device.

  ## Examples

      iex> update_device(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device(%Device{} = device, attrs) do
    device
    |> Device.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a device.

  ## Examples

      iex> delete_device(device)
      {:ok, %Device{}}

      iex> delete_device(device)
      {:error, %Ecto.Changeset{}}

  """
  def delete_device(%Device{} = device) do
    Repo.delete(device)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking device changes.

  ## Examples

      iex> change_device(device)
      %Ecto.Changeset{data: %Device{}}

  """
  def change_device(%Device{} = device, attrs \\ %{}) do
    Device.changeset(device, attrs)
  end

  alias MicrocontrollerServer.Microcontroller.Reading

  @doc """
  Returns the list of readings.

  ## Examples

      iex> list_readings()
      [%Reading{}, ...]

  """
  def list_readings do
    Repo.all(Reading)
    |> Repo.preload([sensor: [:device]])
  end

  @doc """
  Gets a single reading.

  Raises `Ecto.NoResultsError` if the Reading does not exist.

  ## Examples

      iex> get_reading!(123)
      %Reading{}

      iex> get_reading!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reading!(id) do
    Repo.get!(Reading, id)
    |> Repo.preload([sensor: [:device]])
  end

  @doc """
  Creates a reading.

  ## Examples

      iex> create_reading(%{field: value})
      {:ok, %Reading{}}

      iex> create_reading(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reading(attrs \\ %{}) do
    %Reading{}
    |> Reading.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Insert multiple readings at the same time. Similar to `create_reading/1`, only that it retuns
  an array when it's completed.
  """
  @spec create_readings(attrs :: [map()]) ::
    {:ok, %{readings: {number_of_rows :: integer(), nil}}} |
    {:error, [Ecto.Changeset.t()]}
  def create_readings(attrs \\ []) do
    changesets =
      attrs
      |> Enum.map(&change_reading(%Reading{}, &1))

    attrs =
      changesets
      |> Enum.map(fn element -> Map.take(element.changes, [:sensor_id, :type, :value]) end)

    if all_changesets_valid?(changesets) do
      attrs = add_timestamps(attrs)

      {:ok, %{readings: {_, readings}}} =
        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:readings, Reading, attrs, returning: true)
        |> Repo.transaction()

      {:ok, readings}
    else
      {:error, changesets}
    end
  end

  defp all_changesets_valid?(changesets) do
    Enum.all?(changesets, &Enum.empty?(&1.errors))
  end

  defp add_timestamps(attrs) do
    Enum.map(attrs, &add_timestamp(&1))
  end

  defp add_timestamp(attrs) do
    attrs
    |> Map.merge(Map.from_keys([:inserted_at, :updated_at], NaiveDateTime.truncate(NaiveDateTime.utc_now, :second)))
  end

  @doc """
  Updates a reading.

  ## Examples

      iex> update_reading(reading, %{field: new_value})
      {:ok, %Reading{}}

      iex> update_reading(reading, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reading(%Reading{} = reading, attrs) do
    reading
    |> Reading.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reading.

  ## Examples

      iex> delete_reading(reading)
      {:ok, %Reading{}}

      iex> delete_reading(reading)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reading(%Reading{} = reading) do
    Repo.delete(reading)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reading changes.

  ## Examples

      iex> change_reading(reading)
      %Ecto.Changeset{data: %Reading{}}

  """
  def change_reading(%Reading{} = reading, attrs \\ %{}) do
    Reading.changeset(reading, attrs)
  end

  alias MicrocontrollerServer.Microcontroller.Sensor

  @doc """
  Returns the list of sensors.

  ## Examples

      iex> list_sensors()
      [%Sensor{}, ...]

  """
  def list_sensors do
    Repo.all(Sensor)
  end

  @doc """
  Gets all of the sensor values for the given device.

  ## Examples

      iex> list_sensors_for_device(device_id)
      [%Sensor{}, %Sensor{}]
  """
  @spec list_sensors_for_device(device_id :: integer()) :: [Sensor.t()]
  def list_sensors_for_device(device_id) do
    from(
      sensor in Sensor,
        where: sensor.device_id == ^device_id
    )
    |> Repo.all
  end

  @doc """
  Gets a single sensor.

  Raises `Ecto.NoResultsError` if the Sensor does not exist.

  ## Examples

      iex> get_sensor!(123)
      %Sensor{}

      iex> get_sensor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sensor!(id), do: Repo.get!(Sensor, id)

  @doc """
  Load the ecto relation with readings for a sensor.
  """
  def load_sensor_with_readings(sensors), do: Repo.preload(sensors, [:readings])

  @doc """
  Load the ecto relation with the device for a sensor.
  """
  def load_sensor_with_device(sensors), do: Repo.preload(sensors, [:device])

  @doc """
  Creates a sensor.

  ## Examples

      iex> create_sensor(%{field: value})
      {:ok, %Sensor{}}

      iex> create_sensor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sensor(attrs \\ %{}) do
    %Sensor{}
    |> Sensor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sensor.

  ## Examples

      iex> update_sensor(sensor, %{field: new_value})
      {:ok, %Sensor{}}

      iex> update_sensor(sensor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sensor(%Sensor{} = sensor, attrs) do
    sensor
    |> Sensor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sensor.

  ## Examples

      iex> delete_sensor(sensor)
      {:ok, %Sensor{}}

      iex> delete_sensor(sensor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sensor(%Sensor{} = sensor) do
    Repo.delete(sensor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sensor changes.

  ## Examples

      iex> change_sensor(sensor)
      %Ecto.Changeset{data: %Sensor{}}

  """
  def change_sensor(%Sensor{} = sensor, attrs \\ %{}) do
    Sensor.changeset(sensor, attrs)
  end
end
