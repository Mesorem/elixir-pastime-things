defmodule XYChat.Y do
  alias XYChat.Y

  @type t :: %Y{}
  defstruct type: nil, payload: nil

  #####  @interface

  # @spec new(String.t:type, term:payload \\ nil) :: %Y{}
  def new(type, payload \\ nil) do
    %Y{type: type, payload: payload}
  end
end
