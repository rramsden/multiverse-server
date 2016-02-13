defmodule Multiverse.Event do
  use GenEvent

  def init(pid) do
    {:ok, pid}
  end

  def handle_event(e, pid) do
    GenSever.cast(pid, e)
    {:ok, pid}
  end

  def handle_call(req, pid) do
    send(pid, req)
    {:ok, :ok, pid}
  end

  def handle_info(e, pid) do
    send(pid, e)
    {:ok, pid}
  end
end
