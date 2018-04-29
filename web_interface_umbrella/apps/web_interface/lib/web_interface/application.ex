defmodule WebInterface.Application do
  @moduledoc """
  The WebInterface Application Service.

  The web_interface system business domain lives in this application.

  Exposes API to clients such as the `WebInterfaceWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      
    ], strategy: :one_for_one, name: WebInterface.Supervisor)
  end
end
