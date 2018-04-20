defmodule PlayerSupervisorTest do

	use ExUnit.Case

	test "Can start PlayerSupervisor" do
		GAME.PlayerSupervisor.start_link
	end

	test "Can make a new player" do
		
		GAME.PlayerSupervisor.start_link
		GAME.PlayerRegistry.start_link

		GAME.PlayerSupervisor.new_player("Jim")

		assert GAME.PlayerRegistry.whereis_name("Jim") != :undefined
		assert Map.get(DynamicSupervisor.count_children(:player_sup), :active) == 1

	end

	test "PlayerSup restarts player if it dies" do
		
		GAME.PlayerSupervisor.start_link
		GAME.PlayerRegistry.start_link

		GAME.PlayerSupervisor.new_player("Jim")

		pid1 = GAME.PlayerRegistry.whereis_name("Jim")

		GAME.PlayerAgent.damage(pid1, 20)

		assert Map.get(GAME.PlayerAgent.health(pid1), :health) == 80

		Process.exit(pid1, :kill)

		assert Map.get(DynamicSupervisor.count_children(:player_sup), :active) == 1

		# Works. God, we needed to wait for the change to PROPOGATE??
		pid2 = GAME.PlayerRegistry.whereis_name("Jim")
		
		assert Map.get(GAME.PlayerAgent.health(pid2), :health) == 100

	end

end

defmodule PlayerAgentTest do

	use ExUnit.Case

	test "Can make a new player" do
		GAME.PlayerAgent.create("Jim")
	end

	test "registering a new player works" do

		GAME.PlayerRegistry.start_link

		{:ok, pid} = GAME.PlayerAgent.create("Jim")
		GAME.PlayerAgent.register("Jim", pid)

		assert GAME.PlayerRegistry.whereis_name("Jim") == pid

	end

end

defmodule PlayerRegistryTest do

	use ExUnit.Case

	test "Can start PlayerRegistry" do
		GAME.PlayerRegistry.start_link
	end

	test "Can register a new player" do
		GAME.PlayerRegistry.start_link
		{:ok, pid} = GAME.PlayerAgent.create("Jim")
		assert GAME.PlayerRegistry.register_name("Jim", pid) == :ok
	end

	test "Can find player" do
		GAME.PlayerRegistry.start_link
		{:ok, pid} = GAME.PlayerAgent.create("Jim")
		GAME.PlayerRegistry.register_name("Jim", pid)
		assert GAME.PlayerRegistry.whereis_name("Jim") == pid
	end
	
end



