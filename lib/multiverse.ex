defmodule Multiverse do
  use Application

  def start(_type, _args) do
    Network.Supervisor.start_link
  end

  def version do
    project_version = Multiverse.Mixfile.project[:version]
    [{major, _}, {minor, _}, {patch, _}] = Enum.map(String.split(project_version, "."), &Integer.parse/1)
    %{major: major, minor: minor, patch: patch}
  end
end
