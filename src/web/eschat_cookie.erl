%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Jan 2025 12:04 pm
%%%-------------------------------------------------------------------
-module(eschat_cookie).
-author("student").

-define(COOKIE_TTL, 3600).

-define(COOKIE_OPTS, #{
%%  domain => <<"">>,
  http_only => true,
  path => <<"/">>,
  same_site => strict,
  secure => true,
  max_age => ?COOKIE_TTL
  }).

%% API
-export([set_cookie/3]).
-export([set_cookie/4]).


set_cookie(Key, Val, Req) ->
  set_cookie(Key, Val, Req, ?COOKIE_OPTS).

set_cookie(Key, Val, Req, COOKIEOPTS) ->
  cowboy_req:set_resp_cookie(Key, Val, Req, COOKIEOPTS).