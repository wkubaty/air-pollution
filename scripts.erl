%%%-------------------------------------------------------------------
%%% @author wojciech
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. maj 2017 16:55
%%%-------------------------------------------------------------------
-module(scripts).
-author("wojciech").

%% API
-export([script1/0, script2/0, script3/0]).

script1() ->
  M = pollution:createMonitor(),
  {ok, M1} = pollution:addStation("Krakow", {10, 20}, M),
  {ok, M2} = pollution:addStation("Warszawa", {100, 200}, M1),
  {ok, M3} = pollution:addValue("Krakow", {{2017,5,10}, {2,2,2}}, "PM10", 100, M2),
  pollution:getOneValue("Krakow", {{2017,5,10}, {2,2,2}}, "PM10", M2),
  {ok, M4} = pollution:addValue("Warszawa", {{2017,5,10}, {2,2,2}}, "PM10", 1000, M3),
  pollution:removeValue("Krakow", {{2017,5,10}, {2,2,2}}, "PM10", M4),
  pollution:getOneValue("Warszawa", {{2017,5,10}, {2,2,2}}, "PM10", M4),
  pollution:getDailyMean({{2017,5,10}, {2,2,2}}, "PM10", M4).

script2() ->
  rPollution_gen_server:start_link(a),
  rPollution_gen_server:addStation("Krakow", {10, 20}),
  rPollution_gen_server:addStation("Warszawa", {100, 200}),
  rPollution_gen_server:addValue("Krakow", {{2017,5,10}, {2,2,2}}, "PM10", 100),
  rPollution_gen_server:addValue("Krakow", {{2017,5,10}, {12,2,2}}, "PM10", 200),
  rPollution_gen_server:addValue("Warszawa", {{2017,5,10}, {2,2,2}}, "PM10", 1000),
  rPollution_gen_server:removeValue("Krakow", {{2017,5,10}, {2,2,2}}, "PM10"),
  rPollution_gen_server:getOneValue("Warszawa", {{2017,5,10}, {2,2,2}}, "PM10"),
  rPollution_gen_server:getDailyMean({{2017,5,10}, {2,2,2}}, "PM10"),
  rPollution_gen_server:getStationMean("Krakow", "PM10").
script3()->ok.
