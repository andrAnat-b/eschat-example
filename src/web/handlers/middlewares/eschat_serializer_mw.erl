%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Feb 2025 1:50 pm
%%%-------------------------------------------------------------------
-module(eschat_serializer_mw).
-author("student").
-behavior(cowboy_middleware).
%% API
-export([name/0]).
-export([execute/2]).

name() -> ?MODULE.

execute(Req, Env) ->
  lager:debug("Serializer Req ~p", [Req]),
  lager:debug("Serializer Env ~p", [Env]),
  {ok, Req, Env}.