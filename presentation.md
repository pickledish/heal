---
theme: solarized
revealOptions:
    transition: 'slide'
---

# Elixir Game

---

## What is Elixir?

Improved (or at least different) Erlang, similar to how:
- Scala is to Java <!-- .element: class="fragment" -->
- CoffeeScript is to JavaScript <!-- .element: class="fragment" -->
- Hack is to PHP <!-- .element: class="fragment" -->

---

## What is Elixir?

But, it compiles to the same BEAM VM bytecode, and the foundational constructs are inherited

So, in order to understand Elixir... <!-- .element: class="fragment" -->

---

## What is Erlang?

- A general-purpose, concurrent, functional programming language <!-- .element: class="fragment" -->

- The BEAM VM, garbage collected, excellent at scheduling "fake" threads <!-- .element: class="fragment" -->

- The OTP (Open Telecom Platform) set of design principles and components <!-- .element: class="fragment" -->

---

## Key Elements of Erlang/OTP

- Created to improve telephony applications

- Distributed, fault-tolerant, and real-time

---

## The Upshot

By the OTP model, an Erlang application will make thousands of cheap threads, 
which have state but only communicate via a robust message passing network

The trick is that all are governed by "Supervisors" <!-- .element: class="fragment" -->

---

## A Supervision Tree

---

<img src="/proposal/diagram.png">

---

## Boss Supervisor

```Elixir
defmodule GAME.BossSupervisor do

	use Supervisor

	def start_link(_) do
		Supervisor.start_link(__MODULE__, :ok, name: :boss_sup)
	end

	def init(:ok) do
		children = [GAME.BossAgent]
		Supervisor.init(children, strategy: :one_for_one)
	end

end
```

---

## Player Supervisor

```Elixir
defmodule GAME.PlayerSupervisor do

	use DynamicSupervisor

	def start_link(_) do ... end

	def init(:ok) do
		DynamicSupervisor.init(strategy: :one_for_one)
	end

	def new_player(name) do
		spec = %{id: name, start: {GAME.PlayerAgent, :start_link}}
		DynamicSupervisor.start_child(:player_sup, spec)
	end
end
```

---

## Input (Tasks)

```Elixir
def getResponse(socket) do
	case :gen_tcp.recv(socket, 0) do
		{:error, _} -> {:ok, "Socket has been closed"}
		{:ok, data} -> case parse data do
			{:signup, name}       -> newPlayer(name)
			{:command, name, msg} -> sendMessage(name, msg)
			{:info}               -> getStatus()
			{:kill, name}         -> kill(name)
			{:error}              -> {:ok, "Not recognized?\n"}
		end
	end
end
```

---

## Player Registry

```Elixir
def whereis_name(player_name) do ... end

def register_name(player_name, pid) do ... end

def unregister_name(player_name) do ... end

def dispatch(message) do ... end

# -------------------------------------------------------------

def handle_cast({:dispatch, message}, state) do
	for {_, pid} <- state do GenServer.call(pid, message) end
	{:noreply, state}
end
```

---

## Why A Game?

- The game isn't even fun

- The boss Charlie doesn't die when he reaches 0 HP

- Healing the boss is trivially easy

---

## Why A Game?

- Player Agents &nbsp; `=>` &nbsp; same model for harder tasks 

- Process Registry idea is so common, there's one built in to Erlang/OTP that I didn't know about <!-- .element: class="fragment" -->

- Wanted to try out the BEAM VM for myself <!-- .element: class="fragment" -->

---

# THANKS








