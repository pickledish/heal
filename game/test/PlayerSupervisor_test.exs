defmodule PlayerSupervisorTest do

	use ExUnit.Case

	setup do
		:ets.new(:health_cache, [:named_table, :public])
		GAME.PlayerSupervisor.start_link
		GAME.PlayerRegistry.start_link
		:ok
	end

	test "Can make a new player" do
		GAME.PlayerSupervisor.new_player("Jim")
		assert GAME.PlayerRegistry.whereis_name("Jim") != :undefined
		children = DynamicSupervisor.count_children(:player_sup)
		assert Map.get(children, :active) == 1
	end

	test "PlayerSup restarts player if it dies" do
		GAME.PlayerSupervisor.new_player("Jim")
		pid = GAME.PlayerRegistry.whereis_name("Jim")
		Process.exit(pid, :kill)
		Process.sleep(1)
		children = DynamicSupervisor.count_children(:player_sup)
		assert Map.get(children, :active) == 1
	end

	test "health is preserved across child deaths" do
		GAME.PlayerSupervisor.new_player("Jim")
		pid1 = GAME.PlayerRegistry.whereis_name("Jim")
		GAME.PlayerAgent.damage(pid1, 20)
		Process.exit(pid1, :kill)
		Process.sleep(1)
		pid2 = GAME.PlayerRegistry.whereis_name("Jim")
		assert Map.get(GAME.PlayerAgent.status(pid2), :health) == 80
	end

end
