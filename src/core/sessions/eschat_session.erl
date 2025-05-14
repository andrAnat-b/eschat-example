%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2025 2:03 pm
%%%-------------------------------------------------------------------
-module(eschat_session).
-author("student").
-include("eschat_models.hrl").
-include("eschat_db.hrl").
-define(SALT, <<"!!![$up3rm3g43Xtr@s4Lt}">>).

%% API
-export([new/0]).
-export([login_user_to_session/2]).
-export([check_session/1]).
-export([drop_session/1]).

new() ->
  Session = #session{
    sid = base64:encode(crypto:hash(sha3_512, [erlang:integer_to_binary(?NOW_SEC), ?SALT]))
  },
  SQL = "INSERT INTO \"Session\" (id) VALUES ($1)",
  #ok{changed = 1} = eschat_db:call_and_cache(SQL, [Session#session.sid]),
  Session#session.sid.

login_user_to_session(Sid, UserId) ->
  SQL = "UPDATE \"Session\" set user_id = $1 where id = $2 and user_id is NULL",
  #ok{changed = 1} = eschat_db:call_and_cache(SQL, [UserId, Sid]),
  ok.

check_session(Sid) ->
  SQL = "SELECT user_id as uid FROM \"Session\" where id = $1 and created_at < CURRENT_TIMESTAMP and active_to >= CURRENT_TIMESTAMP",
  case eschat_db:call_and_cache(SQL, [Sid]) of
    #ok{return = [Result]} -> {ok, Result, Sid};
    #ok{} -> {ok, #{}, new()}
  end.

drop_session(Sid) ->
  #ok{} = eschat_db:call_and_cache("DELETE FROM \"Session\" where id = $1", [Sid]).