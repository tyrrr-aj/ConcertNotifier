-module(concert_generator_sup).

-export([start/0, stop/0]).
-export([supervise/1]).

start() -> spawn(?MODULE, supervise, [self()]).

supervise(Pid) ->
  process_flag(trap_exit, true),
  GeneratorPid = concert_generator:start(Pid),
  register(generator, GeneratorPid),
  receive
    {'EXIT', _, normal} -> io:format("Generator finished work~n");
    {'EXIT', _, _} -> supervise(Pid);
	  stop -> concert_generator:stop(Pid)
  end.

stop() -> self() ! stop.