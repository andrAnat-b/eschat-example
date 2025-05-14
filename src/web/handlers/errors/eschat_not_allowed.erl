%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Jan 2025 1:31 pm
%%%-------------------------------------------------------------------
-module(eschat_not_allowed).
-author("student").
-behavior(cowboy_handler).
%% API
-export([init/2]).


init(Req, _) ->
  cowboy_req:reply(400, #{}, <<"NOT ALLOWED METHOD">>, Req).