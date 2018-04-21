defmodule PlayerAgentTest do

	use ExUnit.Case

	setup do
		:ets.new(:health_cache, [:named_table, :public])
		GAME.PlayerRegistry.start_link(:ok)
		:ok
	end

	test "Can make a new player and affect health" do
		{:ok, pid} = GAME.PlayerAgent.create("Jim")
		GAME.PlayerAgent.damage(pid, 20)
		GAME.PlayerAgent.heal(pid, 50)
		assert GAME.PlayerAgent.status(pid).health == 130
	end

	test "registering a new player works" do
		{:ok, pid} = GAME.PlayerAgent.create("Jim")
		GAME.PlayerAgent.register("Jim", pid)
		assert GAME.PlayerRegistry.whereis_name("Jim") == pid
	end

end