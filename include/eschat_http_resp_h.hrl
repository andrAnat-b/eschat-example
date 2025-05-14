%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2025 1:59 pm
%%%-------------------------------------------------------------------
-author("student").
-record(http_resp,{
  status = 200,
  headers = #{<<"x-api-vsn">> => <<"1">>},
  req = [],
  body = <<>>
}).