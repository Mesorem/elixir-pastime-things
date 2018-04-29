defmodule WebInterface.X do
  alias WebInterface.X

  @type t :: %X{}
  defstruct type: nil, state: nil

  #####  @interface

  @spec new(type, payload) :: X.t() when type: String.t(), payload: term() | nil
  def new(type, state) do
    %X{type: type, state: state}
  end
end
