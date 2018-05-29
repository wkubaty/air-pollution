%%%-------------------------------------------------------------------
%%% @author wojciech
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. maj 2017 11:58
%%%-------------------------------------------------------------------
-module(rPollution_gen_server).
-author("wojciech").
-behaviour(gen_server).
%% API
-export([start_link/1, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getPredictedIndex/3, crash/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

%% START %%
start_link(Arg)   -> gen_server:start_link({local, rPollution_gen_server}, ?MODULE, Arg, []).

%% INTERFEJS KLIENT -> SERWER %%
init(_Arg) -> Monitor = pollution:createMonitor(), {ok, Monitor}.

stop()->gen_server:handle_cast(?MODULE, stop).

addStation(Name, {X, Y}) -> gen_server:call(?MODULE, {addStation, Name, {X, Y}}).
addValue(Stat, Date, Type1, Value) -> gen_server:call(?MODULE, {addValue, Stat, Date, Type1, Value}).
removeValue(Stat, Date, Type) -> gen_server:call(?MODULE, {removeValue, Stat, Date, Type}).
getOneValue(Stat, Date, Type) -> gen_server:call(?MODULE, {getOneValue, Stat, Date, Type}).
getStationMean(Stat, Type)  -> gen_server:call(?MODULE, {getStationMean, Stat, Type}).
getDailyMean({YMD, _HMS}, Type) -> gen_server:call(?MODULE, {getDailyMean, {YMD, _HMS}, Type}).
getPredictedIndex(Stat, Date, Type) -> gen_server:call(?MODULE, {getPredictedIndex, Stat, Date, Type}).
crash() ->gen_server:call(?MODULE, {crash}).
%% OBSŁUGA WIADOMOŚCI %%
handle_call({ok, Monitor}, _, Monitor) -> {reply, ok, Monitor};

handle_call({addStation, Name, {X, Y}}, _, Monitor) ->
  case pollution:addStation(Name, {X, Y}, Monitor) of
    {ok, M} -> {reply, ok, M};
    {ERR, _M} -> {reply, ERR, Monitor}
  end;


handle_call({addValue, Stat, Date, Type1, Value}, _, Monitor) ->
  case pollution:addValue(Stat, Date, Type1, Value, Monitor) of
    {ok, M} -> {reply, ok, M};
    {ERR, _M} -> {reply, ERR, Monitor}
  end;

handle_call({removeValue, Stat, Date, Type}, _,Monitor) ->
  case pollution:removeValue(Stat, Date, Type, Monitor) of
    {ok, M} -> {reply, ok, M};
    {ERR, _M} -> {reply, ERR, Monitor}
  end;

handle_call({getOneValue, Stat, Date, Type}, _,Monitor) ->
  case pollution:getOneValue(Stat, Date, Type, Monitor) of
    {ERR, _M} -> {reply, ERR, Monitor};
    Value -> {reply, Value, Monitor}

  end;

handle_call({getStationMean, Stat, Type}, _, Monitor) ->
  case pollution:getStationMean(Stat, Type, Monitor) of
    {ERR, _M} -> {reply, ERR, Monitor};
    Value -> {reply, Value, Monitor}
  end;

handle_call({getDailyMean, {YMD, _HMS}, Type}, _, Monitor) ->
  case pollution:getDailyMean({YMD, _HMS}, Type, Monitor) of
    {ERR, _M} -> {reply, ERR, Monitor};
    Value -> {reply, Value, Monitor}
  end;

handle_call({getPredictedIndex, Stat, Date, Type}, _, Monitor) ->
  case pollution:predictedIndex(Stat, Date, Type, Monitor) of
    {ERR, _M} -> {reply, ERR, Monitor};
    Value -> {reply, Value, Monitor}

  end;

handle_call({crash}, _, _Monitor) ->
 1/0.
handle_cast(_Reason, State) -> {noreply, State}.

handle_info(Info, State) ->
  {noreply, Info, State}.

terminate(_Reason, _LoopData) -> ok.

%crash - obsluga, supervisor