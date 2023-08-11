# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MicrocontrollerServer.Repo.insert!(%MicrocontrollerServer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import MicrocontrollerServer.Factory

for i <- 1..5, do: insert(:device)
for i <- 1..5, do: insert(:sensor)
for i <- 1..5, do: insert(:reading)
