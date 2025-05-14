%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Jan 2025 1:35 pm
%%%-------------------------------------------------------------------
-module(eschat_chat_h).
-author("student").
-behavior(cowboy_handler).
-include("eschat_http_resp_h.hrl").
%% API
-export([dispatch/0]).
-export([name/0]).

-export([init/2]).

name() -> ?MODULE.

dispatch() -> {"/api/:vsn/chat[/:id]", name(), #{}}.


init(#{method := <<"GET">>, bindings := #{id := _Id}} = Req, Env) ->
  #http_resp{} = Result = eschat_chats:info(Req, Env),
  {ok, eschat_http_body:response(Req, Result), Env};
init(#{method := <<"GET">>} = Req, Env) ->
  #http_resp{} = Result = eschat_chats:list(Req, Env),
  {ok, eschat_http_body:response(Req, Result), Env};
init(#{method := <<"POST">>} = Req, Env) ->
  #http_resp{} = Result = eschat_chats:create(Req, Env),
  {ok, eschat_http_body:response(Req, Result), Env};

init(Req, Env) ->
  eschat_notfound_h:init(Req, Env).