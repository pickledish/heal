defmodule Game.PlayerRegistry do

	use GenServer

	# API ---------------------------------------------------------------------

	def start_link do
		GenServer.start_link(__MODULE__, nil, name: :player_registry)
	end

	def whereis_name(player_name) do
		GenServer.call(:registry, {:whereis_name, player_name})
	end

	def register_name(player_name, pid) do
		GenServer.call(:registry, {:register_name, player_name, pid})
	end

	def unregister_name(player_name) do
		GenServer.cast(:registry, {:unregister_name, player_name})
	end

	def send(player_name, message) do
		case whereis_name(player_name) do
			:undefined -> {:badarg, {player_name, message}}
			pid        -> Kernel.send(pid, message)
		end
	end

	# SERVER ------------------------------------------------------------------

	def init(_) do
		{:ok, Map.new}
	end

	def handle_call({:whereis_name, player_name}, _from, state) do
		{:reply, Map.get(state, player_name, :undefined), state}
	end

	def handle_call({:register_name, room_name, pid}, _from, state) do
		# Our response tuple include a `:no` or `:yes` indicating if
		# the process was included or if it was already present.
		case Map.get(state, room_name) do
			nil -> {:reply, :yes, Map.put(state, room_name, pid)}
			_   -> {:reply, :no, state}
		end
	end

	def handle_cast({:unregister_name, room_name}, state) do
		{:noreply, Map.delete(state, room_name)}
	end

end




