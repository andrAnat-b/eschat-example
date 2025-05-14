%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2025 3:22 pm
%%%-------------------------------------------------------------------
-module(eschat_parser).
-author("student").

%% API
-export([parse/3]).
-export([encode/2]).

parse(_, Body, false) -> {ok, Body};

parse({<<"application">>, <<"json">>, _}, Body, true) ->
  {ok, eschat_json:decode(Body)};

parse(ContentType, Body, HasBody) ->
  lager:error("Unrecognized 'Content-Type: ~p' Body<~p>: ~20.p", [ContentType, HasBody, Body]),
  {error, #{}}.



encode({<<"application">>, <<"json">>, _}, Body) ->
  eschat_json:encode(Body);

encode(Accept, Body) ->
  lager:warning("Unrecognized 'Accept: ~p'", [Accept]),
  eschat_json:encode(Body).