defmodule Player do
	defstruct name: "DEFAULT", health: 100
end

defmodule GAME.PlayerAgent do

	use GenServer

	# API ---------------------------------------------------------------------

	def start_link(player_name) do
		{:ok, pid} = create(player_name)
		register(player_name, pid)
		{:ok, pid}
	end

	def create(player_name) do
		case :ets.lookup(:health_cache, player_name) do
			[{_, hp}] -> 
				GenServer.start_link(__MODULE__, %Player{name: player_name, health: hp})
			[] -> 
				GenServer.start_link(__MODULE__, %Player{name: player_name})
		end
	end

	def register(player_name, pid) do
		GAME.PlayerRegistry.register_name(player_name, pid)
	end

	def damage(pid, amount) do
		GenServer.call(pid, {:change, -1 * amount})
	end

	def heal(pid, amount) do
		GenServer.call(pid, {:change, amount})
	end

	def status(pid) do
		GenServer.call(pid, {:get})
	end

	# SERVER ------------------------------------------------------------------

	def init(state)  do
		{:ok, state}
	end

	def handle_call({:change, amount}, _from, state) do
		new = state.health + amount
		:ets.insert(:health_cache, {state.name, new})
		{:reply, :ok, Map.put(state, :health, new)}
	end

	def handle_call({:get}, _from, state) do
		{:reply, state, state}
	end

end

