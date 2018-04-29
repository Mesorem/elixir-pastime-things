defmodule WebInterfaceWeb.UserChannel do
  use Phoenix.Channel

  alias WebInterface.{X, Hook, User}

  def join("user:" <> name, _message, socket) do
    {:ok, pid} = User.start_link(name, "password")
    send(self(), {:start_change_hook, pid})
    send(self(), {:start_pusher_hook, pid})
    {:ok, Map.put(socket.assign, :user, pid)}
  end

  def handle_in(event, payload, socket) do
    Hook.push(socket.assign.pusher, Y.new(event, payload))
    {:noreply, socket}
  end

  def handle_cast({:change, %X{state: state}}, socket) do
    {:noreply, socket}
  end

  def handle_info({:start_change_hook, subject}, socket) do
    Hook.start_link({:out, self()}, subject)
    {:noreply, socket}
  end

  def handle_info({:start_pusher_hook, subject}, socket) do
    {:ok, pusher} = Hook.start_link(:in, subject)
    {:noreply, Map.put(socket.assign, :pusher, pusher)}
  end

  def handle_info(_info, socket) do
    {:noreply, socket}
  end

end
