%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2025 3:24 pm
%%%-------------------------------------------------------------------
-module(eschat_headers).
-author("student").

-define(ACCEPTIBLE_HEADERS, [
  <<"accept">>,
  <<"accept-charset">>,
  <<"accept-encoding">>,
  <<"accept-language">>,
  <<"access-control-request-headers">>,
  <<"access-control-request-method">>,
  <<"authorization">>,
  <<"connection">>,
  <<"content-encoding">>,
  <<"content-language">>,
  <<"content-length">>,
  <<"content-type">>,
  <<"cookie">>,
  <<"expect">>,
  <<"if-match">>,
  <<"if-modified-since">>,
  <<"if-none-match">>,
  <<"if-range">>,
  <<"if-unmodified-since">>,
  <<"max-forwards">>,
  <<"origin">>,
  <<"proxy-authorization">>,
  <<"range">>,
  <<"sec-websocket-extensions">>,
  <<"sec-websocket-protocol">>,
  <<"sec-websocket-version">>,
  <<"trailer">>,
  <<"upgrade">>,
  <<"x-forwarded-for">>
]).

%% API
-export([parse_headers/1]).


parse_headers(Req) ->
  MHeaders = cowboy_req:headers(Req),
%%  lager:debug("Headers ~p", [MHeaders]),
  LHeaders = maps:to_list(MHeaders),

%%  lager:debug("LHeaders ~p", [LHeaders]),
  LParsedHeaders = [{Key, cowboy_req:parse_header(Key, Req)} || {Key, _}
    <- LHeaders, lists:member(Key, ?ACCEPTIBLE_HEADERS)],

%%  lager:debug("LParsedHeaders ~p", [LParsedHeaders]),
  LParsedHeaders.