# Elixir Game

### Files

All source code is located in the `game` directory. Inside of that folder, there is a folder named `lib` that contains all of the code for the project (the purpose of each file is detailed in the writeup). There is an additional folder called `test` that has a number of files for unit tests. There's also a `config` folder which came with the Mix project (I didn't touch it), and a `build` folder that contains the compiled binaries for the project.

The other directories are self-explanatory: `proposal` contains the documents of the proposal and the writeup, and `client` contains a simple Python program that will query the elixir server and give a constantly-updated view of everyone's health (including the boss's, whose name is Charlie) to help with playing the game.

### Running

The project uses no external Elixir libraries, since it's pretty simple, but it does require the Elixir compiler itself, and the build tools that come with it. Those can be acquired with `brew install elixir` or `apt-get install elixir` or from the Elixir website. 

Then, in order to compile the project, you `cd` into the `game` directory and run `mix compile`, which will store the binaries in the aforementioned `build` folder. Then, `mix run` will start up the Elixir server, and it'll be available to log into.

### Playing

The game is very simple, since making it intricate or particularly engaging wasn't really the point of the project. Once the server is running, you can log in by using `telnet 127.0.0.1 6666`, which should give you a shell for the game, and then make a new player for yourself using `signup $name` with `$name` being your character (no spaces).

Then, you can submit a heal command as `$name heal $target $amount`, with $target being the name of the person you'd like to heal, and $amount being some integer (higher numbers means more healing, and there's no downside -- not a very balanced game). Or, you can spend your time damaging the boss, by typing `$name damage $amount`, in a similar way. You can also heal the boss, Charlie, but it's not recommended.

Note, the game isn't very robust, because I wanted to spend more time getting the message-passing and supervision protocols right. This means that some simple things, like players "dying" once they reach 0 health or ____, aren't implemented.

### Testing