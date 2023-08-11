defmodule MicrocontrollerServer.MicrocontrollerTest do
  use MicrocontrollerServer.DataCase

  import MicrocontrollerServer.Factory

  alias MicrocontrollerServer.Microcontroller
  alias MicrocontrollerServer.Microcontroller.{Device, Reading, Sensor}

  describe "devices" do
    @invalid_attrs %{user_id: nil, location_id: nil}

    test "list_devices/0 returns all devices" do
      device = insert(:device)

      assert Microcontroller.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = insert(:device)
      assert Microcontroller.get_device!(device.id) == device
    end

    test "get_device_by_controller_id/1 return the device with the given controller id" do
      device = insert(:device)

      assert ^device = Microcontroller.get_device_by_controller_id(device.controller_id)

      assert nil == Microcontroller.get_device_by_controller_id(device.controller_id + 1)
    end

    test "create_device/1 with valid data creates a device" do
      device =
        build(:device, user_id: 42, location_id: 42)
        |> Map.from_struct()

      assert {:ok, %Device{} = device} = Microcontroller.create_device(device)
      assert device.user_id == 42
      assert device.location_id == 42
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Microcontroller.create_device(@invalid_attrs)
    end

    test "create_device/1 with repeating controller_id returns error changeset" do
      device = insert(:device)

      device_new = build(:device, controller_id: device.controller_id)

      assert {:error, %Ecto.Changeset{errors: [controller_id: _]}} =
        device_new
        |> Map.from_struct()
        |> Microcontroller.create_device()
    end

    test "update_device/2 with valid data updates the device" do
      device = insert(:device)
      update_attrs = %{user_id: 43, location_id: 43}

      assert {:ok, %Device{} = device} = Microcontroller.update_device(device, update_attrs)
      assert device.user_id == 43
      assert device.location_id == 43
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = insert(:device)
      assert {:error, %Ecto.Changeset{}} = Microcontroller.update_device(device, @invalid_attrs)
      assert device == Microcontroller.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = insert(:device)
      assert {:ok, %Device{}} = Microcontroller.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Microcontroller.get_device!(device.id) end
    end

    test "change_device/1 returns a device changesdevice_fixtureet" do
      device = insert(:device)
      assert %Ecto.Changeset{} = Microcontroller.change_device(device)
    end
  end

  describe "readings" do
    @invalid_attrs %{type: nil, value: nil}

    test "list_readings/0 returns all readings" do
      reading = insert(:reading)
      assert Microcontroller.list_readings() == [reading]
    end

    test "get_reading!/1 returns the reading with given id" do
      reading = insert(:reading)
      assert Microcontroller.get_reading!(reading.id) == reading
    end

    test "create_reading/1 with valid data creates a reading" do
      valid_attrs = %{type: "pressure", value: 120.5}

      assert {:ok, %Reading{} = reading} = Microcontroller.create_reading(valid_attrs)

      assert reading.type == "pressure"
      assert reading.value == 120.5
    end

    test "have correct enumaration of types" do
      reading = insert(:reading, type: "pressure")

      {:ok, type_id} = Microcontroller.ReadingType.dump("pressure")

      assert {:ok, %Postgrex.Result{rows: [[^type_id]]}} = MicrocontrollerServer.Repo.query("SELECT type FROM readings WHERE id = #{reading.id}")

      assert reading.type == "pressure"
    end

    test "create_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Microcontroller.create_reading(@invalid_attrs)
    end

    test "update_reading/2 with valid data updates the reading" do
      reading = insert(:reading)
      update_attrs = %{type: "pressure", value: 7}

      assert {:ok, %Reading{} = reading} = Microcontroller.update_reading(reading, update_attrs)
      assert reading.type == "pressure"
      assert reading.value == 7
    end

    test "update_reading/2 with invalid data returns error changeset" do
      reading = insert(:reading)
      assert {:error, %Ecto.Changeset{}} = Microcontroller.update_reading(reading, @invalid_attrs)
      assert reading == Microcontroller.get_reading!(reading.id)
    end

    test "delete_reading/1 deletes the reading" do
      reading = insert(:reading)
      assert {:ok, %Reading{}} = Microcontroller.delete_reading(reading)
      assert_raise Ecto.NoResultsError, fn -> Microcontroller.get_reading!(reading.id) end
    end

    test "change_reading/1 returns a reading changeset" do
      reading = insert(:reading)
      assert %Ecto.Changeset{} = Microcontroller.change_reading(reading)
    end
  end

  # describe "sensors" do
  #   alias MicrocontrollerServer.Microcontroller.Sensor

  #   import MicrocontrollerServer.MicrocontrollerFixtures

  #   @invalid_attrs %{name: nil}

  #   test "list_sensors/0 returns all sensors" do
  #     sensor = sensor_fixture()
  #     assert Microcontroller.list_sensors() == [sensor]
  #   end

  #   test "get_sensor!/1 returns the sensor with given id" do
  #     sensor = sensor_fixture()
  #     assert Microcontroller.get_sensor!(sensor.id) == sensor
  #   end

  #   test "create_sensor/1 with valid data creates a sensor" do
  #     valid_attrs = %{name: "some name"}

  #     assert {:ok, %Sensor{} = sensor} = Microcontroller.create_sensor(valid_attrs)
  #     assert sensor.name == "some name"
  #   end

  #   test "create_sensor/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Microcontroller.create_sensor(@invalid_attrs)
  #   end

  #   test "update_sensor/2 with valid data updates the sensor" do
  #     sensor = sensor_fixture()
  #     update_attrs = %{name: "some updated name"}

  #     assert {:ok, %Sensor{} = sensor} = Microcontroller.update_sensor(sensor, update_attrs)
  #     assert sensor.name == "some updated name"
  #   end

  #   test "update_sensor/2 with invalid data returns error changeset" do
  #     sensor = sensor_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Microcontroller.update_sensor(sensor, @invalid_attrs)
  #     assert sensor == Microcontroller.get_sensor!(sensor.id)
  #   end

  #   test "delete_sensor/1 deletes the sensor" do
  #     sensor = sensor_fixture()
  #     assert {:ok, %Sensor{}} = Microcontroller.delete_sensor(sensor)
  #     assert_raise Ecto.NoResultsError, fn -> Microcontroller.get_sensor!(sensor.id) end
  #   end

  #   test "change_sensor/1 returns a sensor changeset" do
  #     sensor = sensor_fixture()
  #     assert %Ecto.Changeset{} = Microcontroller.change_sensor(sensor)
  #   end
  # end
end
