%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Dec 2024 1:11 pm
%%%-------------------------------------------------------------------
-module(eschat_xpath).
-author("student").

-define(IS_STRUCT(S), is_list(S) or is_map(S)).
-define(NOTFOUND_IN_PATH, {undefined, nil}).
%% API
-export([get_val/2, get_val/3]).
-export([x_get_val/2, x_get_val/3]).


get_val(Key, Struct) ->
  get_val(Key, Struct, undefined).

get_val(Key, Struct, Default) when is_list(Struct) ->
  case lists:keyfind(Key, 1, Struct) of
    {_, Value} -> Value;
    false -> Default
  end;
get_val(Key, Struct, Default) when is_map(Struct) ->
  Map = maps:merge(#{Key => Default}, Struct),
  maps:get(Key, Map).

x_get_val(Path, Struct) ->
  x_get_val(Path, Struct, undefined).

x_get_val(Path, Struct, Default) ->
  case do_x_get_val(Path, Struct, ?NOTFOUND_IN_PATH) of
    ?NOTFOUND_IN_PATH -> Default;
    Value -> Value
  end.


do_x_get_val([Key|Rest], Struct, Undef) ->
  case do_get_val(Key, Struct, Undef) of
    Undef -> Undef;
    Other ->
      do_x_get_val(Rest, Other, Undef)
  end;
do_x_get_val([], Struct, _Undef) -> Struct.

do_get_val({Index}, Struct, _Undef)
  when (is_integer(Index) > 0)
  and is_list(Struct)
  and length(Struct) =< Index
  ->
  lists:nth(Index, Struct);
do_get_val(Key, Struct, Undef) when ?IS_STRUCT(Struct) ->
  get_val(Key, Struct, Undef);
do_get_val(_, _, Undef) -> Undef.