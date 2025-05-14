%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Jan 2025 1:34 pm
%%%-------------------------------------------------------------------
-module(eschat_user_h).
-author("student").
-behavior(cowboy_handler).

-include("eschat_http_resp_h.hrl").

%% API
-export([dispatch/0]).
-export([name/0]).

-export([init/2]).

name() -> ?MODULE.

dispatch() ->  {"/api/:vsn/user/:action[/:id]", name(), #{}}.

init(#{method := <<"POST">>, bindings := #{action := <<"login">>}} = Req, Env) ->
  #http_resp{} = Response = eschat_user:login(Req, Env),
  {ok, eschat_http_body:response(Req, Response), Env};

init(#{method := <<"GET">>, bindings := #{action := <<"logout">>}} = Req, Env) ->
  #http_resp{} = Response = eschat_user:logout(Req, Env),
  {ok, eschat_http_body:response(Req, Response), Env};

init(#{method := <<"GET">>, bindings := #{action := <<"status">>}} = Req, Env) ->
  #http_resp{} = Response = eschat_user:status(Req, Env),
  {ok, eschat_http_body:response(Req, Response), Env};

init(#{method := <<"POST">>, bindings := #{action := <<"register">>}} = Req, Env) ->
  #http_resp{} = Response = eschat_user:register(Req, Env),
  {ok, eschat_http_body:response(Req, Response), Env};

init(Req, Env) ->
  lager:debug("Req ~p~nEnv ~p",[Req, Env]),
  eschat_notfound_h:init(Req, Env).