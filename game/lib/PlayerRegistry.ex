defmodule GAME.PlayerRegistry do

	use GenServer

	# API ---------------------------------------------------------------------

	def start_link(_) do
		GenServer.start_link(__MODULE__, :ok, name: :player_reg)
	end

	def whereis_name(player_name) do
		GenServer.call(:player_reg, {:whereis_name, player_name})
	end

	def register_name(player_name, pid) do
		GenServer.call(:player_reg, {:register_name, player_name, pid})
	end

	def unregister_name(player_name) do
		GenServer.cast(:player_reg, {:unregister_name, player_name})
	end

	def dispatch(message) do
		GenServer.cast(:player_reg, {:dispatch, message})
	end

	# SERVER ------------------------------------------------------------------

	def init(_) do
		{:ok, Map.new}
	end

	def handle_call({:whereis_name, player_name}, _from, state) do
		{:reply, Map.get(state, player_name, :undefined), state}
	end

	def handle_call({:register_name, player_name, pid}, _from, state) do
		case Map.get(state, player_name) do
			nil -> {:reply, :ok, Map.put(state, player_name, pid)}
			_   -> {:reply, :rewrite, Map.put(state, player_name, pid)}
		end
	end

	def handle_cast({:unregister_name, player_name}, state) do
		{:noreply, Map.delete(state, player_name)}
	end

	def handle_cast({:dispatch, message}, state) do
		for {_, pid} <- state do
			GenServer.call(pid, message)
		end
		{:noreply, state}
	end

end





















