defmodule WebInterface.User2 do

  use Diet.Transformations

  alias WebInterface.User2

  defstruct [:name]

  reductions do

    { :rle, %{ event: "SET_NAME", payload: name }, user = %User2{} } ->
      { :done, %User2{ user | name: name } }

    { :rle, event, user } ->
      { :done, user }

  end

  def new(username) do
    %User2{name: username}
  end
end
