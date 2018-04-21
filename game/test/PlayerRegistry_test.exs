defmodule PlayerRegistryTest do

	use ExUnit.Case

	setup do
		:ets.new(:health_cache, [:named_table, :public])
		GAME.PlayerRegistry.start_link
		:ok
	end

	test "Can register a new player" do
		{:ok, pid} = GAME.PlayerAgent.create("Jim")
		assert GAME.PlayerRegistry.register_name("Jim", pid) == :ok
	end

	test "Players can re-register correctly" do
		{:ok, pid1} = GAME.PlayerAgent.create("Jim")
		assert GAME.PlayerRegistry.register_name("Jim", pid1) == :ok
		{:ok, pid2} = GAME.PlayerAgent.create("Jim")
		assert GAME.PlayerRegistry.register_name("Jim", pid2) == :rewrite
	end

	test "Can find player in registry" do
		{:ok, pid} = GAME.PlayerAgent.create("Jim")
		GAME.PlayerRegistry.register_name("Jim", pid)
		assert GAME.PlayerRegistry.whereis_name("Jim") == pid
	end
	
end