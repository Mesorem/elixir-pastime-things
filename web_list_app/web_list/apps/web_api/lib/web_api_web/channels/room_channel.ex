defmodule WebApiWeb.RoomChannel do

  def join("room:" <> looby, _params, socket) do
    {:ok, socket}
  end

end
