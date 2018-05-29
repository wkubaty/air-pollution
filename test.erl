%%%-------------------------------------------------------------------
%%% @author wojciech
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. kwi 2017 12:41
%%%-------------------------------------------------------------------
-module(test).
-author("wojciech").

-include_lib("eunit/include/eunit.hrl").
-export([testAll/0]).

simple_test() ->
  ?assert(true).
% Date = calendar:local_time(),

testAll()->
  addStation_test(), addValue_test(), getStationMean_test(), getOneValue_test(), getDailyMean_test(), removeValue_test(), getPredictedIndex_test().

addStation_test() ->
  M = pollution:createMonitor(),
  {A, M2} = pollution:addStation("Krakow", {10, 20}, M),
  {B, M3} = pollution:addStation("Krakow", {10, 20}, M),
  {C, _} = pollution:addStation("Krakow", {20, 30}, M2),
  {D, _} = pollution:addStation("Warszawa", {10, 20}, M2),
  {E, _} = pollution:addStation("Krakow", {10, 20}, M3),
  ?assertEqual(ok, A),
  ?assertEqual(ok, B),
  ?assertEqual(M2, M3),
  ?assertEqual({error, stationAlreadyExists}, C),
  ?assertEqual({error, stationAlreadyExists}, D),
  ?assertEqual({error, stationAlreadyExists}, E).

addValue_test() ->
  {ok, P} = pollution:addStation("Stacja", {5, 10}, pollution:createMonitor()),
  Date = calendar:local_time(),
  {ok, P1} = pollution:addValue("Stacja", Date, "PM2,5", 23, P),
  {ok, P2} = pollution:addValue({5, 10}, Date, "PM2,5", 23, P),
  ?assertEqual(P1, P2),
  {_, P3} = pollution:addValue("xxx", Date, "PM2,5", 23, P),
  {_, P4} = pollution:addValue({2,3}, Date, "PM2,5", 23, P),
  ?assertEqual(P3, P),
  ?assertEqual(P4, P),
  {_, P5} = pollution:addValue("Stacja", Date, "PM2,5", 23, P1),
  {_, P6} = pollution:addValue({5, 10}, Date, "PM2,5", 23, P1),
  ?assertEqual(P1, P5),
  ?assertEqual(P1, P6),
  {_, P7} = pollution:addValue("Stacja", Date, "PM2,5", 18, P1),
  {_, P8} = pollution:addValue({5, 10}, Date, "PM2,5", 18, P1),
  ?assertEqual(P7, P1),
  ?assertEqual(P8, P1).

getStationMean_test() ->
  M = pollution:createMonitor(),
  {ok, M1} = pollution:addStation("Krak", {40.234, 54.234}, M),
  {ok, M2} = pollution:addValue("Krak", {{2017,5,1},{20,10,58}}, "PM10", 20, M1),
  {ok, M3} = pollution:addValue("Krak", {{2017,5,1},{20,10,59}}, "PM10", 30, M2),
  {ok, M4} = pollution:addValue("Krak", {{2017,5,1},{20,11,00}}, "PM2,5", 400, M3),
  {ok, M5} = pollution:addValue("Krak", {{2017,5,1},{20,11,01}}, "PM2,5", 500, M4),
  ?assertEqual(25.0, pollution:getStationMean("Krak", "PM10", M5)),
  ?assertEqual(450.0, pollution:getStationMean({40.234, 54.234}, "PM2,5", M5)).


getOneValue_test() ->
  P = pollution:createMonitor(),
  {ok, P1} = pollution:addStation("Krak_Aleje", {40.23, 54.23}, P),
  {ok, P2} = pollution:addValue("Krak_Aleje", {{2017,5,8},{15,11,20}}, "PM10", 250, P1),
  {ok, P3} = pollution:addValue("Krak_Aleje", {{2017,5,8},{15,31,20}}, "PM10", 300, P2),
  ?assertEqual(250, pollution:getOneValue("Krak_Aleje", {{2017,5,8},{15,11,20}},  "PM10", P3)),
  ?assertEqual(300, pollution:getOneValue("Krak_Aleje", {{2017,5,8},{15,31,20}}, "PM10", P3)).

getDailyMean_test()->
  P = pollution:createMonitor(),
  {ok, P1} = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  {ok, P2} = pollution:addValue({50.2345, 18.3445}, {{2017,4,30},{20,29,50}}, "PM10", 59, P1),
  {ok, P3} = pollution:addValue("Aleja Słowackiego", {{2017,4,30},{20,29,50}}, "PM2,5", 113, P2),
  {ok, P4} = pollution:addValue({50.2345, 18.3445}, {{2017,4,30},{08,29,50}}, "PM2,5", 90, P3),
  ?assertEqual(101.5, pollution:getDailyMean({{2017,4,30}, {11,11,11}}, "PM2,5", P4)).

removeValue_test()->
  P = pollution:createMonitor(),
  {ok, P1} = pollution:addStation("xDStation", {12.548, 55.136}, P),
  {ok, P2} = pollution:addValue("xDStation", {{2017,9,5},{21,12,13}}, "PM10", 99, P1),
  {ok, P3} = pollution:addValue("xDStation", {{2017,9,5},{15,30,55}}, "PM2,5", 173, P2),
  {ok, P4} = pollution:addValue("xDStation", {{2017,9,5},{10,10,10}}, "PM2,5", 80, P3),
  {ok, P5} = pollution:removeValue("xDStation",{{2017,9,5},{10,10,10}},"PM2,5", P4),
  ?assertEqual(P3, P5).

getPredictedIndex_test() ->
  Date1={{2017,5,1}, {10,11,13}}, %przykladowa zbyt wczesna data
  Date2={{2017,5,8}, {10,11,13}},
  Date3={{2017,5,9}, {8,34,34}},
  M = pollution:createMonitor(),
  {ok, M2} = pollution:addStation("Krakow", {10, 20}, M),
  {ok, M3} = pollution:addValue({10, 20}, Date1, "PM10", 100, M2),
  {ok, M4} = pollution:addValue({10, 20}, Date2, "PM10", 200, M3),
  {ok, M5} = pollution:addValue({10, 20}, Date3, "PM10", 300, M4),
  Date4={{2017,5,9}, {9,21,21}},
  ?assertEqual(250.0, pollution:getPredictedIndex({10, 20}, Date4, "PM10", M5)).
