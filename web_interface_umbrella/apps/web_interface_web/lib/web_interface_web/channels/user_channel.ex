defmodule WebInterfaceWeb.UserChannel do
  use Phoenix.Channel

  require Logger

  alias WebInterface.{X, Hook, User, Y}

  def join("user:" <> name, _message, socket) do
    {:ok, pid} = User.start_link(name, "password")
    send(self(), {:start_pusher_hook, pid})
    send(self(), {:start_change_hook, pid})
    {:ok, socket |> assign(:user, pid) |> assign(:user_id, name)}
  end

  def handle_in(event, payload, socket) do
    event
    |> Y.new(payload)
    |> Hook.push(socket.assigns.pusher)
    {:noreply, socket}
  end

  def handle_cast({:change, %X{state: state}}, socket) do
    {:noreply, socket}
  end

  def handle_info({:start_change_hook, subject}, socket) do
    Logger.info("Starting change hook for user #{socket.assigns.user_id}...")
    Hook.start_link(:out, subject)
    Logger.info("Started change hook for user #{socket.assigns.user_id}.")
    {:noreply, socket}
  end

  def handle_info({:start_pusher_hook, subject}, socket) do
    Logger.info("Starting pusher hook for user #{socket.assigns.user_id}...")
    {:ok, pusher} = Hook.start_link(:in, subject)
    Logger.info("Started pusher hook for user #{socket.assigns.user_id}.")
    {:noreply, assign(socket, :pusher, pusher)}
  end

  def handle_info(_info, socket) do
    {:noreply, socket}
  end

end
