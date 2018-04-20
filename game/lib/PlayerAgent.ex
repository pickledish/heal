defmodule Player do
	defstruct name: "PLAYER", health: 100
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
		GenServer.start_link(__MODULE__, %Player{name: player_name})
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

	def health(pid) do
		GenServer.call(pid, {:get})
	end

	# SERVER ------------------------------------------------------------------

	def init(state)  do
		{:ok, state}
	end

	def handle_call({:change, amount}, _from, state) do
		updater = fn (health) -> health + amount end
		{:reply, :ok, Map.update(state, :health, 0, updater)}
	end

	def handle_call({:get}, _from, state) do
		{:reply, state, state}
	end

end

