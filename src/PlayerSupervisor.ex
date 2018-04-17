defmodule Game.PlayerSupervisor do
	
	use DynamicSupervisor

	def start_link(opts) do

		DynamicSupervisor.start_link(__MODULE__, :ok, name: :player_sup)

	end

	def init(:ok) do

		DynamicSupervisor.init(strategy: :one_for_one)

	end

	def new_player(name) do

		spec = %{id: Game.PlayerAgent, start: {Game.PlayerAgent, :create, [name]}}
		DynamicSupervisor.start_child(:player_sup, spec)

	end

end