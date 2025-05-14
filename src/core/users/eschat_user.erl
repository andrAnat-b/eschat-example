-module(eschat_user).
-author("student").

-include("eschat_db.hrl").
-include("eschat_http_resp_h.hrl").

-export([login/2]).
-export([logout/2]).
-export([status/2]).
-export([register/2]).

%% API
login(_Req, _Env) ->
  lager:debug("_Req -> ~p :|:===:|: _Env ~p", [_Req, _Env]),
  Username = eschat_xpath:x_get_val([eschat_parser_mw:name(), <<"login">>], _Req, <<>>),
  Password = eschat_xpath:x_get_val([eschat_parser_mw:name(), <<"passw">>], _Req, <<>>),
  SQL = "SELECT id from \"User\" where login = $1 and passwd = $2",
  case eschat_db:call_and_cache(SQL, [Username, Password]) of
    #ok{return = []} ->
      #http_resp{status = 404, body = {error, user_notfound}};
    #ok{return = [#{id := _Id}= Result|_] } ->
      case _Req of
        #{eschat_cookie_mw := #{auth := true, uid := _Id}} ->
          #http_resp{status = 200, body = Result};
        #{eschat_cookie_mw := #{auth := true}} ->
          #http_resp{status = 403, body = {error, unauthorized}};
        _Other ->
          [_ ,_ ,SetCookie|_] = eschat_xpath:x_get_val([resp_cookies, <<"_sid">>], _Req, [null, null, <<>>]),
          Sid = eschat_xpath:x_get_val([eschat_cookie_mw, sid], _Req, SetCookie),
          eschat_session:login_user_to_session(Sid, _Id),
          #http_resp{status = 200, body = Result}
      end
  end.

logout(_Req, _Env) ->
  _Other = eschat_xpath:x_get_val([eschat_cookie_mw, sid], _Req, <<>>),
  lager:debug("< < _Other ::: ~p > >",[_Other]),
  eschat_session:drop_session(_Other),
  #http_resp{status = 200, req = [], body = true}.

status(#{eschat_cookie_mw := #{auth := true}} = Req, _Env) ->
  SQL = "SELECT login from \"User\" login WHERE id = $1",
  Result = eschat_db:call_and_cache(SQL,[eschat_xpath:x_get_val([eschat_cookie_mw:name(), uid],Req)]),
  case Result of
    #ok{return = [Ret|_]} ->
      #http_resp{status = 200, body = Ret};
    #ok{} ->
      #http_resp{status = 200, body = {error, undefined}};
    _ ->
      #http_resp{status = 502, body = {error, 'Something went wrong'}}
  end;
status(#{eschat_cookie_mw := #{auth := false}} = _Req, _Env) ->
  #http_resp{status = 403, body = {error, unauthorized}}.

register(_Req, _Env) ->
  SQL = "INSERT INTO \"User\" (login, passwd) VALUES ($1, $2) ON CONFLICT DO NOTHING RETURNING id",
  Username = eschat_xpath:x_get_val([eschat_parser_mw:name(), <<"login">>], _Req, <<>>),
  Password = eschat_xpath:x_get_val([eschat_parser_mw:name(), <<"passw">>], _Req, <<>>),
  Result = eschat_db:call_and_cache(SQL,[Username, Password]),
  lager:debug("Result call => ~p",[Result]),
  case Result of
    #ok{changed = 1, return = Ret} ->
      #http_resp{status = 200, body = Ret};
    _ ->
      #http_resp{status = 502, body = {error, 'Something went wrong'}}
  end.