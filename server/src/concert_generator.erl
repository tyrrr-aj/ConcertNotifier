-module(concert_generator).

-export([start/1, start/0, stop/1, stop/0, subscribe/0, unsubscribe/0, loop/1]).

-define(MAX_INTERVAL_SECONDS, 3).

start(Pid) -> 
	Own = spawn_link(?MODULE, loop, [[Pid]]),
	register(con_gen, Own),
	Own.

start() ->
	Own = spawn_link(?MODULE, loop, [[]]),
	register(con_gen, Own),
	Own.

stop(Pid) -> Pid ! stop,
			ok.

stop() ->
	con_gen ! stop.

subscribe() ->
	con_gen ! {subscribe, self()}.

unsubscribe() ->
	con_gen ! {unsubscribe, self()}.

loop(Pids) ->
	Interval = get_random_interval(),
	receive_and_notify(Pids, Interval).

receive_and_notify(Pids, Delay) ->
	Timestamp = erlang:system_time(millisecond),
	receive
		{subscribe, SubscribentPid} -> 
			RemainingDelay = Delay - (erlang:system_time(millisecond) - Timestamp),
			io:format("GEN: Received subscription request from ~p~n", [SubscribentPid]),
			receive_and_notify(Pids ++ [SubscribentPid], RemainingDelay);
		{unsubscribe, Pid} -> 
			RemainingDelay = Delay - (erlang:system_time(millisecond) - Timestamp),
			io:format("GEN: Received subscription request from ~p~n", [Pid]),
			receive_and_notify(lists:delete(Pid, Pids), RemainingDelay);
		stop -> ok;
		crash -> non_existing_module:non_existing_function()
	after
		Delay ->
			{{Band, Genre}, City} = Concert = concerts:get_random_concert(),
			%io:format("GEN: generated concert {{~s, ~s}, ~ts}~n", [Band, Genre, City]),
			notify_all(Pids, Concert),
			loop(Pids)
	end.

get_random_interval() -> rand:uniform(?MAX_INTERVAL_SECONDS) * 1000.

notify_all(Pids, Concert) ->
	%io:format("GEN: notifying ~p~n", [Pids]),
	lists:foreach(fun(Pid) -> Pid ! Concert end, Pids).