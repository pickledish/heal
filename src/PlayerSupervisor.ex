defmodule Game.PlayerSupervisor do
	
	use DynamicSupervisor

	def start_link(opts) do

		DynamicSupervisor.start_link(__MODULE__, :ok, name: :player_sup)


	def init(:ok) do

		DynamicSupervisor.init(strategy: :one_for_one)

	end

	def new_player(name) do

		spec = %{id: Player, start: {Game.Player, :create, [name]}}
		start_child(__MODULE__, spec)

	end

end