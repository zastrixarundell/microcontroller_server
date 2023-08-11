defmodule MicrocontrollerServerWeb.MicrocontrollerSocket.Channels.V1 do
  use MicrocontrollerServerWeb, :channel

  @moduledoc false

  require Logger

  @impl true
  def join("microcontroller:v1:" <> _mc_id, payload, socket) do
    Logger.debug("Payload during MC join on V1: #{payload}")

    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (v1:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  def authorized?(_payload) do
    true
  end
end
