defmodule GamePort do

	use GenServer

	# This determines what we do based on the content of the message
	def getResponse(packet) do
		case String.split(packet) do
			["signup"] -> "Welcome Aboard"
			_		   -> "Command not recognized"
		end
	end

	# This is what we call to set the server running for the first time
	def start_link() do
		ippp = Application.get_env :tcp_server, :ip, {127,0,0,1}
		port = Application.get_env :tcp_server, :port, 6666
		GenServer.start_link(__MODULE__, [ippp, port], [])
	end

	# Thanks to implementing GenServer, this is run whenever we start up
	def init [ip, port] do
		args = [:binary, {:packet, 0}, {:active, true}, {:ip, ip}]
		{:ok, listen_socket} = :gen_tcp.listen(port, args)
		{:ok, socket} = :gen_tcp.accept listen_socket
		{:ok, %{ip: ip, port: port, socket: socket}}
	end

	# This is called on every successful TCP packet we take in
	def handle_info({:tcp, socket, packet}, state) do
		IO.inspect packet, label: "incoming packet"
		:gen_tcp.send socket, "Hi Blackode \n"
		{:noreply, state}
	end

	# This is called whenever the person on the other line disconnects
	def handle_info({:tcp_closed, _}, state) do
		IO.inspect "Socket has been closed"
		{:noreply, state}
	end

	# This is called on every unsuccessful TCP packet we take in
	def handle_info({:tcp_error, socket, reason}, state) do
		IO.inspect socket, label: "connection closed dut to #{reason}"
		{:noreply, state}
	end

end