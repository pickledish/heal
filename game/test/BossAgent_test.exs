defmodule BossAgentTest do
	
	use ExUnit.Case

	setup do
		:ets.new(:health_cache, [:named_table, :public])
		GAME.PlayerRegistry.start_link(:ok)
		:ok
	end

	test "Creating a boss works" do
		GAME.BossAgent.start_link(:ok)
		GAME.BossAgent.damage(20)
		assert GAME.BossAgent.status().health == 980
	end

	test "Boss stomp actually damages players" do

		GAME.BossAgent.start_link(:ok)
		{:ok, pid1} = GAME.PlayerAgent.start_link("Jim")
		{:ok, pid2} = GAME.PlayerAgent.start_link("Kelly")

		GAME.BossAgent.stomp()
		Process.sleep(10)

		assert GAME.PlayerAgent.status(pid1).health == 90
		assert GAME.PlayerAgent.status(pid2).health == 90

		Process.sleep(2000) # Wait for the second round of stompin'

		assert GAME.PlayerAgent.status(pid1).health == 80
		assert GAME.PlayerAgent.status(pid2).health == 80

	end

end