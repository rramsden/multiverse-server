defmodule Multiverse.Stats do
  def initial_roll do
    [
      charisma: roll(3),
      constitution: roll(3),
      dexterity: roll(3),
      intelligence: roll(3),
      strength: roll(3),
      wisdom: roll(3)
    ]
  end

  defp roll(n) do
    Enum.sum(for _ <- (1..n), do: :random.uniform(6))
  end
end
