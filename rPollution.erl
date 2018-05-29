%%%-------------------------------------------------------------------
%%% @author wojciech
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. maj 2017 11:32
%%%-------------------------------------------------------------------
-module(rPollution).
-author("wojciech").

%% API
-export([start/0, terminate/0, init/0]).
-export([loop/1]).
-export([rAddStattion/3, rAddValue/5]).
start() ->
  register (rPollution, spawn (?MODULE, init, [])).

init() ->
  Monitor=pollution:createMonitor(),
  loop(Monitor).

loop(Monitor) ->
  receive
    stop ->
      terminate();
    {addStation, Name, {X, Y}, PID} ->
    case pollution:addStation(Name, {X, Y}, Monitor) of
      {ok, Monitor2} -> PID ! ok,
        loop(Monitor2);
      {{error, stationAlreadyExists}, _} -> PID ! {errror, stationAlreadyExists}, loop(Monitor)
    end;
    {addValue, Stat, Date, Type1, Value, PID} ->
      case pollution:addValue(Stat, Date, Type1, Value, Monitor) of
        {ok, Monitor2} -> PID ! ok,
          loop(Monitor2);
        {error, thisMeasureExist} -> PID ! {error, thisMeasureExist}, loop(Monitor);
        {error, thisStationNotExist} -> PID ! {error, error, thisStationNotExist}, loop(Monitor)
      end
  end.

terminate() ->
  ok.

rAddStattion(Name, {X, Y}, PID) -> rPollution ! {addStation, Name, {X, Y}, PID}.
rAddValue(Stat, Date, Type1, Value, PID) -> rPollution ! {addValue, Stat, Date, Type1, Value, PID}.