defmodule InputTest do

	use ExUnit.Case

	test "Info returns not implemented" do
		{:ok, res} = GAME.Input.getResponse("brandon status")
		assert res == "Not implemented"
	end

end
