%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2025 1:41 pm
%%%-------------------------------------------------------------------
-author("student").
-record(ok, {
     changed = 0 :: integer(),
     return = [] :: list(map())
}).

-record(err, {
  severity = error :: atom(),
  code,
  message
}).