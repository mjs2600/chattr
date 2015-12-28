defmodule Chattr.RoomChannel do
  use Phoenix.Channel

  def join("rooms:dev", _message, socket) do
    send self(), :after_join
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "new_msg", %{userName: "me", text: "Hi!"}
    {:noreply, socket}
  end

  def handle_in("new_msg", msg, socket) do
    broadcast! socket, "new_msg", msg
    {:noreply, socket}
  end
end
