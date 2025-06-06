%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Jan 2025 1:29 pm
%%%-------------------------------------------------------------------
-module(eschat_notfound_h).
-author("student").
-behavior(cowboy_handler).
%% API
-export([name/0]).
-export([dispatch/0]).

-export([init/2]).

name() -> ?MODULE.

dispatch() ->
  {'_', name(), #{}}.


init(Req, Env) ->
  {ok, cowboy_req:reply(404, #{}, <<"PAGE NOT FOUND">>, Req), Env}.