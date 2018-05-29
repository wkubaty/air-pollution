%%%-------------------------------------------------------------------
%%% @author wojciech
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. maj 2017 15:46
%%%-------------------------------------------------------------------
-module(rPollution_supervisor).
-author("wojciech").
-behavior(supervisor).

%% API
-export([start_link/1, start_link_shell/1, init/1]).

start_link(InitValue) -> supervisor:start_link({local, rPollution_supervisor}, ?MODULE, InitValue).
start_link_shell(InitValue) -> {ok, Pid} = supervisor:start_link({local, rPollution_supervisor}, ?MODULE, InitValue), unlink(Pid).

init(InitValue) ->
  RestartStrategy = one_for_one,
  MaxRestarts = 2,
  MaxSecondsBetweenRestarts = 2,
  RestartTuple = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
  ChildSpecList = [{rPollution_gen_server, {rPollution_gen_server, start_link, [InitValue]},
    permanent, brutal_kill, worker, [rPollution_gen_server] }],
  {ok, {RestartTuple, ChildSpecList}}.
