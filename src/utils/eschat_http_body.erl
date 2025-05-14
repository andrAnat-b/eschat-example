%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Dec 2024 1:14 pm
%%%-------------------------------------------------------------------
-module(eschat_http_body).
-author("student").
-include("eschat_http_resp_h.hrl").
%% API
-export([read/1]).
-export([response/2]).

read(Req) ->
  do_read(cowboy_req:read_body(Req), <<>>).

do_read({more, Chunk, Req}, Buff) ->
  do_read(cowboy_req:read_body(Req), <<Buff/binary, Chunk/binary>>);
do_read({ok, Chunk, Req}, Buff) ->
  {ok, <<Buff/binary, Chunk/binary>>, Req}.


response(Req, #http_resp{status = Status, headers = Headers, req = Flist, body = Body}) ->
  Req1 = cowboy_req:set_resp_headers(Headers, Req),
%%  lager:debug("Req1 ~p", [Req1]),
%%  lager:debug("Headers ~p", [Headers]),
%%  lager:debug("Flist ~p", [Flist]),
  Req2 = lists:foldl(fun(Fun, Reqq) -> Fun(Reqq) end, Req1, Flist),
%%  lager:debug("Req2 ~p", [Req2]),
  Body2 = case Status >=400 of
    true -> eschat_web_resp:err(Body);
    false -> eschat_web_resp:ok(Body)
  end,
  lager:debug("Body2 ~p", [Body2]),
  cowboy_req:reply(Status, cowboy_req:set_resp_body(Body2, Req2)).
