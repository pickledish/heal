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
		res = {:ok, "Player #{state.name} healed for #{amount}!\n"}
		{:reply, res, Map.put(state, :health, new)}
	end

	def handle_call({:execute, message}, _from, state) do
		case message do
			{:heal, target, amt} -> {:reply, handle_heal(target, amt, state.name), state}
			{:damage, amt}       -> {:reply, handle_damage(amt), state}
			_                    -> {:reply, {:error, "Could not recognize command\n"}, state}
		end
	end

	def handle_call({:get}, _from, state) do
		{:reply, state, state}
	end

	# PRIVATE -----------------------------------------------------------------

	defp handle_send(target, intAmt, us) do
		case GAME.PlayerRegistry.whereis_name(target) do
		    :undefined              -> {:ok, "Player #{target} does not exist!\n"}
		    pid when (target == us) -> {:ok, "Players cannot heal themselves!\n"}
		    pid                     -> GAME.PlayerAgent.heal(pid, intAmt)
		end
	end

	defp handle_heal(target, strAmt, us) do
		case Integer.parse(strAmt) do
			{int, ""} -> handle_send(target, int, us)
			_         -> {:ok, "Could not parse: #{inspect strAmt}\n"}
		end
	end

	defp handle_damage(strAmt) do
		case Integer.parse(strAmt) do
			{int, ""} -> GAME.BossAgent.damage(int)
			_         -> {:ok, "Could not parse: #{inspect strAmt}\n"}
		end
	end

end

