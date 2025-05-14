%%%-------------------------------------------------------------------
%%% @author student
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Dec 2024 11:46 am
%%%-------------------------------------------------------------------
-module(eschat_web_srv).
-author("student").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(eschat_web_srv_state, {id}).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Spawns the server and registers the local name (unique)
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
%% @doc Initializes the server
-spec(init(Args :: term()) ->
  {ok, State :: #eschat_web_srv_state{}} | {ok, State :: #eschat_web_srv_state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  self() ! restart,
  {ok, #eschat_web_srv_state{}}.

%% @private
%% @doc Handling call messages
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #eschat_web_srv_state{}) ->
  {reply, Reply :: term(), NewState :: #eschat_web_srv_state{}} |
  {reply, Reply :: term(), NewState :: #eschat_web_srv_state{}, timeout() | hibernate} |
  {noreply, NewState :: #eschat_web_srv_state{}} |
  {noreply, NewState :: #eschat_web_srv_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #eschat_web_srv_state{}} |
  {stop, Reason :: term(), NewState :: #eschat_web_srv_state{}}).
handle_call(_Request, _From, State = #eschat_web_srv_state{}) ->
  {reply, ok, State}.

%% @private
%% @doc Handling cast messages
-spec(handle_cast(Request :: term(), State :: #eschat_web_srv_state{}) ->
  {noreply, NewState :: #eschat_web_srv_state{}} |
  {noreply, NewState :: #eschat_web_srv_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #eschat_web_srv_state{}}).
handle_cast(_Request, State = #eschat_web_srv_state{}) ->
  {noreply, State}.

%% @private
%% @doc Handling all non call/cast messages
-spec(handle_info(Info :: timeout() | term(), State :: #eschat_web_srv_state{}) ->
  {noreply, NewState :: #eschat_web_srv_state{}} |
  {noreply, NewState :: #eschat_web_srv_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #eschat_web_srv_state{}}).
handle_info(restart, #eschat_web_srv_state{id = Id} = State) ->
  NewId = restart(Id),
  {noreply, State#eschat_web_srv_state{id = NewId}};
handle_info(_Info, State = #eschat_web_srv_state{}) ->
  {noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #eschat_web_srv_state{}) -> term()).
terminate(_Reason, _State = #eschat_web_srv_state{}) ->
  ok.

%% @private
%% @doc Convert process state when code is changed
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #eschat_web_srv_state{},
    Extra :: term()) ->
  {ok, NewState :: #eschat_web_srv_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State = #eschat_web_srv_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

restart(undefined) ->
  Rotes = [
    {'_', [
      eschat_user_h:dispatch(),
      eschat_chat_h:dispatch(),
      eschat_notfound_h:dispatch()
    ]}
  ],
  Dispatch = cowboy_router:compile(Rotes),
  TransportOpts = #{
    connection_type => supervisor,
    handshake_timeout => 2000,
    max_connections => 65536,
%%    logger => module(),
    num_acceptors => 64,
    shutdown => 10000,
    socket_opts => [{port, 8998}]
  },
  ProtoOpts = #{
    env => #{dispatch => Dispatch},
    active_n => 128,
    chunked => true,
    compress_buffering => true,
    compress_threshold => 1024,
    connection_type => supervisor,
    http10_keepalive => true,
    idle_timeout => 5000,
    inactivity_timeout => 4000,
    initial_stream_flow_size => 128,
    linger_timeout => 1000,
    max_keepalive => 16836,
    middlewares => [
      eschat_cookie_mw:name(),
      eschat_parser_mw:name(),
      cowboy_router,
      eschat_validator_mw:name(),
      cowboy_handler,
      eschat_serializer_mw:name()
    ],
    request_timeout => 3000,
    sendfile => true,
    shutdown_timeout => 4500,
    stream_handlers => [
%%      cowboy_metrics_h,
%%      cowboy_tracer_h,
      cowboy_compress_h,
      cowboy_stream_h
    ]
  },
  Status = cowboy:start_clear(?MODULE, TransportOpts, ProtoOpts),
  lager:info("Web server ~p -> ~p : ~p",[?MODULE, Status, TransportOpts]),
  lager:info("Ranch info ~p", [ranch:info()]);
restart(Id) ->
  cowboy:stop_listener(Id),
  restart(undefined).