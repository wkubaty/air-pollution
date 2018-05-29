%%%-------------------------------------------------------------------
%%% @author wojciech
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. kwi 2017 18:56
%%%-------------------------------------------------------------------
-module(pollution).
-author("wojciech").

%% API
-export([createMonitor/0]).
-export([addStation/3]).
-export([addValue/5]).
-export([getKeyByValueFromDict/2]).
-export([removeValue/4]).
-export([getOneValue/4]).
-export([getStationMean/3]).
-export([getDailyMean/3]).
-export([getPredictedIndex/4]).
-export([getStation/2]).
%Monitor::{Station=(Name->{CoordX, CoordY}), Station=>{Date, Type, Value}}

getFirstElem([]) -> throw(emptyList);
getFirstElem([H|_]) -> H.
isTypeOk(Type) ->
  case Type of
    "PM2,5" ->true;
    "PM10" ->true;
    "temperature"->true;
    _ ->false
  end.

getStation({X, Y}, StationsDict) ->
  try getKeyByValueFromDict({X, Y}, StationsDict) of
    StationName -> {StationName, {X, Y}}
  catch
    _:_ -> throw(notExist)
  end;


getStation(StationName, StationsDict) ->
  try dict:fetch(StationName, StationsDict) of
    Coords -> F = getFirstElem(Coords), {StationName, F} %%
  catch
    error:_ -> throw(notExist)
  end.



getKeyByValueFromDict(Val, D) ->
  L = dict:to_list(D), Filtered = lists:filter(fun({_, [V]}) -> V==Val; (_) -> false end, L),
  try getFirstElem(Filtered) of
    {Key, _} ->Key
  catch
    _:B -> throw(B)
  end.

createMonitor() -> {dict:new(), dict:new()}.

addStation(Name, {X, Y}, D={D1, D2}) ->
  try getStation(Name, D1) of

    _ -> {{error, stationAlreadyExists}, D} %jesli znajdzie juz taka stacje w bazie zwroci blad 'stationAlreadyExists'
  catch
    throw:notExist ->
      try getStation({X, Y}, D1) of

        _ -> {{error, stationAlreadyExists}, D} %jesli znajdzie juz taka stacje w bazie zwroci blad 'stationAlreadyExists'
      catch
        throw:notExist -> {ok, {dict:append(Name, {X, Y}, D1), D2}}
      end
  end.

addValue(Stat, Date, Type1, Value, M={Monitor1, Monitor2}) ->
    case isTypeOk(Type1) of
      true ->
        V = {Date, Type1, Value},

        try getOneValue(Stat, Date, Type1, M) of
          {error, badarg} -> Station = getStation(Stat, Monitor1), {ok, {Monitor1, dict:append(Station, V, Monitor2)}};
          {error, wrongStation} -> {{error, wrongStation}, M};
          _ -> {{error, thisMeasureExist}, M}
        catch
          throw:notExist -> {error, thisStationNotExist};
          _:_ -> Station = getStation(Stat, Monitor1), {ok, {Monitor1, dict:append(Station, V, Monitor2)}}
        end;

      _-> wrongType
    end.


removeValue(Stat, Date, Type1, {Monitor1, Monitor2}) ->
  case isTypeOk(Type1) of
    true ->
      Station = {_, Coords1} = getStation(Stat, Monitor1),
      M = dict:filter(fun({_, Coords}, _) -> not(Coords==Coords1) end,  Monitor2),
      List = dict:fetch(Station, Monitor2),
      List2 = lists:filter(fun({Date2, Type, _}) -> not((Date==Date2) and (Type==Type1)) end, List),
      M2 = dict:append_list(Station, List2, M),
      {ok, {Monitor1, M2}};
    _-> wrongType
  end.

getOneValue(Stat, Date, Type1, {Monitor1, Monitor2}) ->
  case isTypeOk(Type1) of
    true ->
      try getStation(Stat, Monitor1) of
        Station ->
          try  dict:fetch(Station, Monitor2) of
            List  -> {_, _, Value} = getFirstElem(lists:filter(fun({D, T, _}) -> ((D==Date) and (T==Type1)) end, List)), Value
          catch
            error:badarg -> {error, badarg}
          end

      catch
        throw:notExist -> {error, wrongStation}

      end;

    _-> {error, wrongType}
  end.

getStationMean(Stat, Type1, {Monitor1, Monitor2}) ->
  case isTypeOk(Type1) of
    true ->
      try getStation(Stat, Monitor1) of
        Station ->
          try  dict:fetch(Station, Monitor2) of
            List -> List2 = lists:filter(fun({_, T, _}) -> (T==Type1) end, List),
              List3 = lists:map(fun({_, _, V}) -> V end, List2),
              lists:sum(List3)/length(List3)
            catch
              error:badarg ->{error, noValues};
              error:X ->{error, X}
              end
          catch
              throw:notExist ->{error, wrongStation}
      end;
    _-> wrongType
  end.

getDailyMean({YMD, _}, Type1, {_, Monitor2}) ->
  case isTypeOk(Type1) of
    true ->
      List = dict:fold(fun(_, V, A) ->V++A end, [], Monitor2),
      try lists:filter(fun({{YMD2, _}, Type, _}) -> ((YMD2==YMD) and (Type==Type1)) end, List) of
        List2->
          try lists:map(fun({_, _, V}) -> V end, List2) of
            List3 -> lists:sum(List3)/length(List3)
          catch
            error:X ->{error, X}
          end
        catch
          error:X ->{error, X}
      end;
    _-> wrongType
  end.

% 24h=86400s
is24h({Days,{HH, MM, SS}}) -> (Days*86400+3600*HH+60*MM+SS)=<86400.

getPredictedIndex(Stat, Date, Type1, {Monitor1, Monitor2}) ->
  case isTypeOk(Type1) of
    true ->
      try getStation(Stat, Monitor1) of
        Station ->
          try  dict:fetch(Station, Monitor2) of
            List ->  List2 = lists:filter(fun({D, T, _}) -> ((T==Type1) and is24h(calendar:time_difference(D, Date))) end, List),
              List3 = lists:map(fun({_, _, V}) -> V end, List2), lists:sum(List3)/length(List3)
          catch
            error:badarg ->{error, noValues};
            error:X ->{error, X}
          end
      catch
            throw:notExist ->{error, wrongStation}
      end;
   _-> wrongType
end.