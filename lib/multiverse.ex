defmodule Multiverse do
  use Application

  def start(_type, _args) do
    entities = [
      Multiverse.Session
    ]
    game_config = %{entities: entities}
    Multiverse.Service.start_link(game_config)
  end

  def version do
    project_version = Multiverse.Mixfile.project[:version]
    [{major, _}, {minor, _}, {patch, _}] = Enum.map(String.split(project_version, "."), &Integer.parse/1)
    %{major: major, minor: minor, patch: patch}
  end
end
