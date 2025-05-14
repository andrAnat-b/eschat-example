%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2025 12:43 pm
%%%-------------------------------------------------------------------
-module(eschat_web_resp).
-author("student").

-define(OK(Body), #{status => ok, response => Body}).
-define(ERR(Type, Description), #{status => error, err => #{type => Type, descr => Description}}).

%% API
-export([ok/1]).
-export([err/1]).

ok(JsonBody) when is_binary(JsonBody) ->
  eschat_json:encode(?OK({{json, JsonBody}}));
ok(JsonBody) ->
  ok(eschat_json:encode(JsonBody)).

err({Type, Descr}) when is_binary(Type) and is_binary(Descr) ->
  eschat_json:encode(?ERR({{json, Type}}, {{json, Descr}}));
err({Type, Descr}) when is_binary(Descr) ->
  err({eschat_json:encode(Type), Descr});
err({Type, Descr}) when is_binary(Type) ->
  err({Type, eschat_json:encode(Descr)});
err({Type, Descr})->
  err({eschat_json:encode(Type), eschat_json:encode(Descr)}).
