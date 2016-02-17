defmodule Multiverse do
  use Application

  def start(_type, _args) do
    Network.Supervisor.start_link
  end

  def version do
    [{major, _}, {minor, _}, {patch, _}] = Enum.map(String.split("0.0.1", "."), &Integer.parse/1)
    %{major: major, minor: minor, patch: patch}
  end
end
