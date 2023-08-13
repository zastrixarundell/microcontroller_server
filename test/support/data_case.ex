defmodule MicrocontrollerServer.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use MicrocontrollerServer.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias MicrocontrollerServer.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import MicrocontrollerServer.DataCase
    end
  end

  @doc """
  Assserts element or list of elements whether they are equal while ignoring loaded fields.
  """
  def assert_equal_ingore_preloaded(struct_list_1, struct_list_2, fields \\ [], cardinality \\ :one) do
    assert remove_loaded_associations(struct_list_1, fields, cardinality) == remove_loaded_associations(struct_list_2, fields, cardinality)
  end

  @doc """
  Remove loaded associations from an element or list of elements.
  """
  def remove_loaded_associations(struct_with_assoc, fields \\ [], cardinality \\ :one)

  def remove_loaded_associations(struct_with_assoc, fields, cardinality) when is_list(struct_with_assoc) do
    struct_with_assoc
    |> Enum.map(&remove_loaded_associations(&1, fields, cardinality))
  end

  def remove_loaded_associations(struct_with_assoc, fields, cardinality) do
    fields =
      if is_list(fields) do
        fields
      else
        List.wrap(fields)
      end

    fields
    |> Enum.reduce(struct_with_assoc, fn field, acc -> forget(acc, field, cardinality) end)
  end

  defp forget(struct, field, cardinality) do
    %{struct |
      field => %Ecto.Association.NotLoaded{
        __field__: field,
        __owner__: struct.__struct__,
        __cardinality__: cardinality
      }
    }
  end

  setup tags do
    MicrocontrollerServer.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MicrocontrollerServer.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
