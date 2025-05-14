%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2025 12:55 pm
%%%-------------------------------------------------------------------
-module(eschat_db).
-author("student").

-include("eschat_db.hrl").
-include_lib("epgsql/include/epgsql.hrl").

-define(POOL_NAME, database).
-define(DEFAULT, #{
  timeout => 1000,
  cache_negative => false,
  ttl => 5000
}).

-export([call_and_cache/2]).
-export([call_and_cache/3]).

%% API
call_and_cache(SQLorStatement, Params) ->
  call_and_cache(SQLorStatement, Params, #{}).

call_and_cache(SQLorStatement, Params, Opts) ->
  case get_from_cache(SQLorStatement, Params, Opts) of
    {true, Res} -> Res;
    false -> do_call_and_cache(SQLorStatement, Params, Opts)
  end.

is_statement(_) -> {false, fun epgsql:equery/3}.


cache(_SQLorStatement, _Params, _Result) -> ok.

do_call_and_cache(SQLorStatement, Params, Opts) ->
  ResOpt = maps:merge(?DEFAULT, Opts),
  Result0 = case is_statement(SQLorStatement) of
             {true, _Fun} -> ok;
             {_, Fun} ->
               PoolFun = fun(Worker) -> epgsql:with_transaction(Worker, fun(TWorker) -> Fun(TWorker, SQLorStatement, Params) end) end,
               sherlock:transaction(?POOL_NAME, PoolFun, maps:get(timeout, ResOpt))
           end,
  Result = response_to_map(SQLorStatement, Params, Result0),
  cache(SQLorStatement, Params, Result),
  Result.

%%cache_key(SQLorStatement, Params) -> crypto:hash(sha3_512, [SQLorStatement, Params]).

get_from_cache(_SQLorStatement, _Params, _Opts) ->
%%  cache_key(_SQLorStatement, _Params),
  false.

response_to_map(_Sql, _Params, {ok, N, C, R}) ->
  lager:debug("Sql -> ~p <~p>::: N -> ~p ;;; C -> ~p ;;; R -> ~p", [_Sql, _Params, N, C, R]),
  ColumnsMap = columns(C),
  F = fun(El) ->
    maps:from_list([{K, erlang:element(I, El)} || {K, I} <- ColumnsMap])
      end,
  #ok{changed = N, return = [F(Row) || Row <-R]};
response_to_map(_Sql, _Params, {ok, C, R}) ->
  lager:debug("Sql -> ~p <~p>::: C -> ~p ;;; R -> ~p", [_Sql, _Params, C, R]),
  ColumnsMap = columns(C),
  F = fun(El) ->
    maps:from_list([{K, erlang:element(I, El)} || {K, I} <- ColumnsMap])
      end,
  #ok{return = [F(Row) || Row <-R]};
response_to_map(_Sql, _Params, {ok, C}) ->
  lager:debug("Sql -> ~p <~p>::: C -> ~p ;;; R -> ~p", [_Sql, _Params, C, nil]),
  #ok{changed = C};
response_to_map(_Sql, _Params, #error{severity = S, code = C, message = M} = Err) ->
  lager:debug("Sql -> ~p <~p>::: Err -> ~p", [_Sql, _Params, C, Err]),
  #err{severity = S, code = C, message = M};
response_to_map(_Sql, _Params, Other) ->
  lager:debug("Sql -> ~p <~p>::: Other -> ~p", [_Sql, _Params, Other]),
  #err{severity = undefined, code = Other, message = undefined}.

columns([]) -> [];
columns(C) ->
  Names = [erlang:binary_to_atom(Col#column.name) || Col <- C],
  lists:zip(Names, lists:seq(1, length(C))).