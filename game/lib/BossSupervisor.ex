defmodule GAME.BossSupervisor do

	use Supervisor

	def start_link(_) do

		# We can give it the atom name :boss_sup since there'll only be one
		Supervisor.start_link(__MODULE__, :ok, name: :boss_sup)

	end

	def init(:ok) do

		children = [GAME.BossAgent]
		Supervisor.init(children, strategy: :one_for_one)

	end

end