defmodule Multiverse.Command do
  def login(pid, login, password) do
    {:ok, session} = Multiverse.Session.init(pid)
    Multiverse.Session.login(session, login, password)
  end
end
