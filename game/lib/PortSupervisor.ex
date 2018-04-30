defmodule GAME.PortSupervisor do

	use GenServer

	# API ---------------------------------------------------------------------

	def start_link(_) do
		ippp = Application.get_env :tcp_server, :ip, {127,0,0,1}
		port = Application.get_env :tcp_server, :port, 6666
		GenServer.start_link(__MODULE__, [ippp, port], [])
	end

	# SERVER ------------------------------------------------------------------
	
	def init [ip, port] do
		accept(ip, port)
	end

	def accept(ip, port) do
		opts = [:binary, packet: :line, active: false, ip: ip, reuseaddr: true]
		{:ok, socket} = :gen_tcp.listen(port, opts)
		loop_acceptor(socket)
	end

	defp loop_acceptor(socket) do
		{:ok, client} = :gen_tcp.accept(socket)
		fun = fn -> GAME.Input.serve(client) end
		{:ok, pid} = Task.Supervisor.start_child(GAME.TaskSupervisor, fun)
		:ok = :gen_tcp.controlling_process(client, pid)
		loop_acceptor(socket)
	end

end