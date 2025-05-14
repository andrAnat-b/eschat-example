%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Feb 2025 12:14 am
%%%-------------------------------------------------------------------
-module(eschat_validator_mw).
-author("student").
-behavior(cowboy_middleware).
%% API
-export([name/0]).
-export([execute/2]).

name() -> ?MODULE.

execute(Req, Env) ->
  {ok, Req, Env}.