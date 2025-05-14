%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Jan 2025 1:31 pm
%%%-------------------------------------------------------------------
-module(eschat_forbidden).
-author("student").
-behavior(cowboy_handler).
%% API
-export([init/2]).


init(Req, _) ->
  cowboy_req:reply(403, #{}, <<"ACCESS DENIED">>, Req).