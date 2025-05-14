%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Feb 2025 11:20 pm
%%%-------------------------------------------------------------------
-module(eschat_parser_mw).
-author("student").
-behavior(cowboy_middleware).

-define(DEFAULT_CT, {<<"plain">>,<<"text">>,[]}).
%% API
-export([execute/2]).
-export([name/0]).

name() -> ?MODULE.

execute(Req, Env) ->
  Headers = eschat_headers:parse_headers(Req),
  {ok, RawBody, Req1} = eschat_http_body:read(Req),
  {T, St, _} = CT = eschat_xpath:get_val(<<"content-type">>, Headers, ?DEFAULT_CT),
  Result = eschat_parser:parse(CT, RawBody, cowboy_req:has_body(Req)),
  case Result of
    {ok, ParsedBody} -> {ok, Req1#{name() => ParsedBody}, Env};
    {error, _Body} ->
      {stop, cowboy_req:reply(400, #{}, <<"Unaceptable CT : ", T/binary,"/", St/binary>>,Req1)}
  end.