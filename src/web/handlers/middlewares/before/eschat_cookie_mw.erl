%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Feb 2025 11:25 am
%%%-------------------------------------------------------------------
-module(eschat_cookie_mw).
-author("student").
-behavior(cowboy_middleware).

-define(SID_SALT1, <<"GIcoTEHyKUU6I12B5I7fEg==">>).
-define(SID_SALT2, <<"WEVDGcxEKpYO9PQo6NaPag==">>).
-define(SID_SALT3, <<"Mq7GWB8H52yaXu995JR/zg==">>).
-define(TTL_TIME, erlang:system_time(millisecond) + 5000).
-define(NOW, erlang:system_time(millisecond)).
-define(UID_DEFAULT_VAL, <<"null">>).

-define(SID_KEY,  <<"_sid">>).
-define(SIGN_KEY, <<"_sig">>).
-define(TS_KEY,   <<"__ts">>).
-define(UID_KEY,  <<"_uid">>).

-record(ok, {
  req,
  env
}).

%% API
-export([execute/2]).
-export([name/0]).

name() -> ?MODULE.

execute(Req, Env) ->
  KVList = cowboy_req:parse_cookies(Req),
  SidCook = eschat_xpath:get_val(?SID_KEY,  KVList, <<"deleted">>),
  SigCook = eschat_xpath:get_val(?SIGN_KEY, KVList, <<"0">>),
  TSCook  = eschat_xpath:get_val(?TS_KEY,   KVList, <<"0">>),
  UIDCook = eschat_xpath:get_val(?UID_KEY,  KVList, ?UID_DEFAULT_VAL),
  case is_tsb_valid(TSCook) of
    true ->
      GenSign = generate_sign(SidCook, TSCook, UIDCook),
      case (GenSign == SigCook) of
        true ->
          #ok{req = Req#{name() => (#{uid => try_to_int(UIDCook)})#{auth => true, sid => SidCook}}, env = Env};
        _ ->
          #ok{} = do_check_session(Req, Env, SidCook)
      end;
    _ ->
      #ok{} = do_check_session(Req, Env, SidCook)
  end.

do_check_session(Req, Env, SidCook) ->
  case check_session(SidCook) of
    {ok, #{uid := UId} = Res, SidCook} ->
      ProperUid = proper_uid(UId),
      TTL = erlang:integer_to_binary(?TTL_TIME),
      Cookies = [
        {?SID_KEY, SidCook},
        {?TS_KEY, TTL},
        {?SIGN_KEY, generate_sign(SidCook, TTL, ProperUid)}
        | replace_proper_uid(ProperUid)
      ],
      Req1 = cookie_setter(Req, Cookies),
      #ok{env = Env, req = Req1#{name() => Res#{auth => true, sid => SidCook}}};
    {ok, #{}, NewSid} ->
      TTL = erlang:integer_to_binary(?TTL_TIME),
      Cookies = [
        {?SID_KEY, NewSid},
        {?TS_KEY, TTL},
        {?SIGN_KEY, generate_sign(NewSid, TTL, ?UID_DEFAULT_VAL)}
      ],
      Req1 = cookie_setter(Req, Cookies),
      #ok{req = (Req1#{name() => (#{uid => null})#{auth => false, sid => NewSid}}), env = Env}
  end.

generate_sign(<<"B64:",Sid/binary>>, Timestamp, Uid) ->
  generate_sign(Sid, Timestamp, Uid);
generate_sign(Sid, Timestamp, Uid) when is_binary(Sid) and is_binary(Timestamp) and is_binary(Uid) ->
  Hash = crypto:hash(sha3_512, [?SID_SALT3, Sid, ?SID_SALT1, Timestamp, ?SID_SALT2, Uid]),
  <<"B64:", (base64:encode(Hash))/binary>>;
generate_sign(Sid, Timestamp, Uid) when is_integer(Timestamp) ->
  generate_sign(Sid, erlang:integer_to_binary(Timestamp), Uid);
generate_sign(Sid, Timestamp, Uid) when is_integer(Uid) ->
  generate_sign(Sid, Timestamp, erlang:integer_to_binary(Uid)).



try_to_int(Val) ->
  try
    binary_to_integer(Val)
  catch
    _E:_C:_S -> (-1)
  end.

cookie_setter(Req, Props) ->
  Fun = fun({K, V}, Acc) -> eschat_cookie:set_cookie(K, V, Acc) end,
  lists:foldl(Fun, Req, Props).


is_tsb_valid(TSB) ->
  (try_to_int(TSB) - ?NOW) > 0.

check_session(SidCook) ->
  eschat_session:check_session(SidCook).

proper_uid(null) ->
  ?UID_DEFAULT_VAL;
proper_uid(Uid) ->
  erlang:integer_to_binary(Uid).

replace_proper_uid(?UID_DEFAULT_VAL) ->
  [];
replace_proper_uid(Uid) ->
  [{?UID_KEY, Uid}].