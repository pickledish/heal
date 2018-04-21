defmodule GAME do

	use Application

	def start(_type, _args) do

		IO.puts "I'm running!"

		:ets.new(:health_cache, [:named_table, :public])

		children = [GAME.PlayerSupervisor, GAME.PlayerRegistry]
		options  = [strategy: :one_for_one, name: GAME.Supervisor]

		Supervisor.start_link(children, options)

	end
end
