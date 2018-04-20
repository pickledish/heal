defmodule GAME.PlayerSupervisor do

	use DynamicSupervisor

	def start_link() do

		# We can give it the atom name :player_sup since there'll only be one
		DynamicSupervisor.start_link(__MODULE__, :ok, name: :player_sup)

	end

	def init(:ok) do

		# Called for us on start_link because we implement DynamicSupervisor
		DynamicSupervisor.init(strategy: :one_for_one)

	end

	def new_player(name) do

		spec = %{id: name, start: {GAME.PlayerAgent, :start_link, [name]}}
		DynamicSupervisor.start_child(:player_sup, spec)

	end

end