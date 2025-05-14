%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Feb 2025 11:54 pm
%%%-------------------------------------------------------------------
-module(eschat_chats).
-author("student").
-include("eschat_http_resp_h.hrl").
-include("eschat_db.hrl").
%% API
-export([list/2]).
-export([create/2]).
-export([rename/2]).
-export([delete/2]).
-export([join/2]).
-export([leave/2]).
-export([info/2]).

list(Req, _Env) ->
  SQL =
    "SELECT ctab.* FROM "
    "\"Chat\" as ctab RIGHT JOIN "
    "\"ChatMember\" as cmemtab "
      "ON cmemtab.chat_id = ctab.id "
    "WHERE cmemtab.user_id = $1",
  UId = eschat_xpath:x_get_val([eschat_cookie_mw, uid],Req, null),
  case eschat_db:call_and_cache(SQL, [UId]) of
    #ok{return = Return} ->
      #http_resp{status = 200, body = Return};
    _other ->
      #http_resp{status = 502, body = {error, 'Failure'}}
  end.


create(Req, _Env) ->
  SQL =
    "WITH new_chat as ("
      "INSERT INTO \"Chat\" "
      "(name) "
      "VALUES ($1) "
      "RETURNING id "
    "), new_member as ("
      "INSERT INTO \"ChatMember\" "
      "(chat_id, user_id, is_owner) "
      "SELECT id, $2, true "
      "FROM new_chat "
      "RETURNING 'created' as status "
    ") "
    "SELECT * FROM new_member, new_chat ",
  ChatName = eschat_xpath:x_get_val([eschat_parser_mw, <<"name">>], Req, <<"New Chat (",(erlang:integer_to_binary(erlang:system_time(seconds)))/binary,")">>),
  UserId = eschat_xpath:x_get_val([eschat_cookie_mw, uid], Req, null),
  case eschat_db:call_and_cache(SQL, [ChatName, UserId]) of
    #ok{return = [Ret]} ->
      #http_resp{status = 200, body = Ret};
    _other ->
      #http_resp{status = 502, body = {error, 'Can\'t create chat'}}
  end.

join(Req, _Env) ->
  SQL =
    "INSERT INTO public.\"ChatMember\" "
    "(chat_id, user_id) "
    "SELECT $1, $3 "
    "FROM "
	  "public.\"ChatMember\" "
    "WHERE "
	  "chat_id = $1 AND "
    "user_id = $2 AND "
	  "is_owner = true",
  ChatId  = eschat_xpath:x_get_val([eschat_parser_mw, <<"chat_id">>], Req, null),
  UserId  = eschat_xpath:x_get_val([eschat_parser_mw, <<"user_id">>], Req, null),
  OwnerId = eschat_xpath:x_get_val([eschat_cookie_mw, uid], Req, null),
  case eschat_db:call_and_cache(SQL, [ChatId, OwnerId, UserId]) of
    #ok{changed = 0} ->
      #http_resp{status = 403, body = {error, access_denied}};
    #ok{changed = N} ->
      #http_resp{status = 200, body = N};
    _other ->
      #http_resp{status = 502, body = {error, 'Can\'t join user to chat'}}
  end.

delete(Req, _Env) ->
  OwnerId = eschat_xpath:x_get_val([eschat_cookie_mw, uid], Req, null),
  ChatId = eschat_xpath:x_get_val([bindings, id], Req, <<"-1">>),
  SQL1 = "SELECT true WHERE user_id = $1 and chat_id = $2 and is_owner = true",
  ChatIdInt = erlang:binary_to_integer(ChatId),
  case eschat_db:call_and_cache(SQL1, [OwnerId, ChatIdInt]) of
    #ok{return = [_]} ->
      #http_resp{} = do_wipe_chat(ChatIdInt);
    #ok{return = []} ->
      #http_resp{status = 403, body = {error, forbidden}};
    _other ->
      #http_resp{status = 502, body = {error, 'Something went wrong'}}
  end.

leave(Req, _Env) ->
  UserId  = eschat_xpath:x_get_val([eschat_parser_mw, <<"user_id">>], Req, null),
  ChatId  = eschat_xpath:x_get_val([eschat_parser_mw, <<"chat_id">>], Req, null),
  OwnerId = eschat_xpath:x_get_val([eschat_cookie_mw, uid], Req, null),
  case UserId of
    null -> %% non admin user left channel
      #http_resp{} = do_left_channel(ChatId, OwnerId);
    User -> %% admin kick user
      #http_resp{} = do_kick_user(ChatId, OwnerId, UserId)
  end.

info(Req, _Env) ->
  SQL =
    "SELECT ctab.* FROM "
    "\"Chat\" as ctab RIGHT JOIN "
    "\"ChatMember\" as cmemtab "
    "ON cmemtab.chat_id = ctab.id "
    "WHERE cmemtab.user_id = $1 and ctab.id = $2",
  UId = eschat_xpath:x_get_val([eschat_cookie_mw, uid],Req, null),
  ChatId = eschat_xpath:x_get_val([bindings, id],Req, null),
  case eschat_db:call_and_cache(SQL, [UId, erlang:binary_to_integer(ChatId)]) of
    #ok{return = [Return|_]} ->
      SQL2 = "SELECT * FROM "
        "\"ChatMember\" "
        "WHERE chat_id = $1",
      case eschat_db:call_and_cache(SQL2, [erlang:binary_to_integer(ChatId)]) of
        #ok{return = Return2} ->
          #http_resp{status = 200, body = Return#{members => Return2}};
        _other ->
          #http_resp{status = 502, body = {error, 'Failure#2'}}
      end;
    _other ->
      #http_resp{status = 502, body = {error, 'Failure#1'}}
  end.

rename(Req, _Env) ->
  SQL =
    "UPDATE \"\" ",
  #http_resp{status = 400, body = {error, not_implemented}}.

%% ==========================================================================================
%% ==========================================================================================
%% ==========================================================================================

do_left_channel(ChatId, OwnerId) ->
  SQL =
    "DELETE FROM \"ChatMember\" "
    "WHERE chat_id = $1 "
    "AND user_id = $2 "
    "AND is_owner = false",
  case eschat_db:call_and_cache(SQL, [ChatId, OwnerId]) of
    #ok{changed = 0} ->
      #http_resp{status = 400, body = {error, can_not_left_chat}};
    #ok{changed = 1} ->
      #http_resp{status = 200, body = ok};
    _other ->
      #http_resp{status = 502, body = {error, 'Something went wrong'}}
  end.

do_kick_user(ChatId, OwnerId, UserId) ->
  SQL1 =
    "SELECT 1 FROM \"ChatMember\" "
    "WHERE chat_id = $1 "
    "AND is_owner = true "
    "AND user_id = $2 "
    "AND $2 <> $3",
  case eschat_db:call_and_cache(SQL1, [ChatId, OwnerId, UserId]) of
    #ok{return = []} ->
      #http_resp{status = 403, body = {error, 'Access denied'}};
    #ok{return = [_]} ->
      SQL2 =
        "DELETE FROM \"ChatMember\" "
        "WHERE chat_id = $1 "
        "AND user_id = $2",
      case eschat_db:call_and_cache(SQL2, [ChatId, UserId]) of
        #ok{changed = 1} ->
          #http_resp{status = 200, body = ok};
        #ok{} ->
          #http_resp{status = 404, body = {error, undefined}};
        _other ->
          #http_resp{status = 502, body = {error, 'Something went wrong'}}
      end;
    _other ->
      #http_resp{status = 502, body = {error, 'Something went wrong'}}
  end.

do_wipe_chat(ChatId) ->
  SQL2 =
    "WITH delete_members as ("
      "DELETE FROM \"ChatMember\" "
      "WHERE chat_id = $1"
    ") delete_messages as ( "
      "DELETE FROM \"ChatMessage\" "
      "WHERE chat_id = $1"
    ") delete_chat as ( "
      "DELETE FROM \"Chat\" "
      "WHERE id = $1 "
    ") "
    "SELECT 1 FROM delete_members, delete_messages, delete_chat",
  case eschat_db:call_and_cache(SQL2, [ChatId]) of
    #ok{return = [_]} ->
      #http_resp{status = 200, body = ok};
    #ok{return = []} ->
      #http_resp{status = 404, body = undefined};
    _other ->
      #http_resp{status = 502, body = {error, 'Something went wrong'}}
  end.