defmodule Player do
	defstruct name: "PLAYER", health: 100
end

defmodule Game.PlayerAgent do

	# Takes in a player's name, makes a new player, returns his/her PID
	def create(player_name) do
		player = %Player{name: player_name}
		{:ok, pid} = Agent.start_link(fn -> player end)
		res = Game.PlayerRegistry.register_name(player_name, pid)
		IO.puts res
		pid
	end

	# Tells the agent associated with PID to decrease health by $amount
	def damage(pid, amount) do
		updater = fn (health) -> health - amount end
		Agent.update(pid, fn p -> Map.update(p, :health, 0, updater) end)
		pid
	end

	# Tells the agent associated with PID to increase health by $amount
	def heal(pid, amount) do
		updater = fn (health) -> health + amount end
		Agent.update(pid, fn p -> Map.update(p, :health, 0, updater) end)
		pid
	end

	# Queries the agent to return the current status of the player PID
	def health(pid) do
		Agent.get(pid, fn state -> state end)
	end

end

