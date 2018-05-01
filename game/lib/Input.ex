defmodule GAME.Input do

	def serve(socket) do
		write_line("> ", socket)
		{:ok, res} = getResponse socket
		write_line(res, socket)
		serve socket 
	end

	defp parse(input) do
		case String.split(input) do
			["signup", name]         -> {:signup, name}
			[name, "heal", tgt, amt] -> {:command, name, {:heal, tgt, amt}}
			[name, "damage", amt]    -> {:command, name, {:damage, amt}}
			["status"]               -> {:info}
			["kill", name]           -> {:kill, name}
			_                        -> {:error}
		end
	end

	def getResponse(socket) do
		case :gen_tcp.recv(socket, 0) do
			{:error, _} -> {:ok, "Socket has been closed"}
			{:ok, data} -> case parse data do
				{:signup, name}       -> newPlayer(name)
				{:command, name, msg} -> sendMessage(name, msg)
				{:info}               -> getStatus()
				{:kill, name}         -> kill(name)
				{:error}              -> {:ok, "Command not recognized?\n"}
			end
		end
	end

	def sendMessage(player_name, message) do
		pid = GAME.PlayerRegistry.whereis_name(player_name)
		GenServer.call(pid, {:execute, message})
	end

	def newPlayer(player_name) do
		pid = GAME.PlayerSupervisor.new_player(player_name)
		{:ok, "New player started running at PID #{inspect pid}\n"}
	end

	def getStatus() do
		GAME.PlayerRegistry.status()
	end

	def kill(player_name) do
		res = GAME.PlayerRegistry.whereis_name(player_name)
		case res do
		    :undefined -> {:ok, "No such player exists to kill\n"}
		    pid ->
				Process.exit(pid, :kill)
				{:ok, "Process of player #{player_name} has been killed\n"}
		end
	end

	def write_line(line, socket) do
		:gen_tcp.send(socket, line)
	end
	
end