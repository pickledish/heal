defmodule Boss do
	defstruct name: "Charlie", health: 1000
end

defmodule GAME.BossAgent do

	use GenServer

	# API ---------------------------------------------------------------------

	def start_link(_) do
		{:ok, pid} = create()
		register("Charlie", pid)
		{:ok, pid}
	end

	def create() do
		case :ets.lookup(:health_cache, "Charlie") do
			[{_, hp}] -> 
				GenServer.start_link(__MODULE__, %Boss{health: hp}, [name: :boss])
			[] -> 
				GenServer.start_link(__MODULE__, %Boss{}, [name: :boss])
		end
	end

	def register(player_name, pid) do
		GAME.PlayerRegistry.register_name(player_name, pid)
	end

	def stomp() do
		Process.send(:boss, :stomp, [])
	end

	def damage(amount) do
		GenServer.call(:boss, {:change, -1 * amount})
	end

	def heal(amount) do
		GenServer.call(:boss, {:change, amount})
	end

	def status do
		GenServer.call(:boss, {:get})
	end

	# SERVER ------------------------------------------------------------------

	def init(state) do
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

	def handle_info(:stomp, state) do
		message = {:change, -10}
		GAME.PlayerRegistry.dispatch(message)
		Process.send_after(:boss, :stomp, 2000)
		{:noreply, state}
	end

end