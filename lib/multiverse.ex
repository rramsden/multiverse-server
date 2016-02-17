defmodule Multiverse do
  use Application

  def start(_type, _args) do
    Network.Supervisor.start_link
  end
end
