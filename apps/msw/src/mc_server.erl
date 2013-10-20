% Main MC Server manager

-module(mc_server).

-behaviour(gen_server).

-define(SERVER, ?MODULE).

-record(state, {
		options
	}).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([
	launch/1,
	start_link/0
	]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
		terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link() ->
	gen_server:start_link(?MODULE, [], []).

launch(Pid) ->
	gen_server:call(Pid, launch).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(_Args) ->
	process_flag(trap_exit, true),
	Options = [
		{cd, "/home/overminddl1/minecraft/test/"}
		%,{user, "overminddl1"}
		%,{limit_users, "overminddl1"}
		,{stdout, self()}
		,{stderr, self()}
		%,{stdout, {append, "/home/overminddl1/minecraft/test/testing.log"}}
		%,{stderr, fun(Stream, OsPid, Data) -> io:format("~p:~p: ~p~n", [Stream, OsPid, Data]) end}
		%,monitor
	],
	{ok, #state{options=Options}}.


handle_call(launch, _From, #state{options=Options} = State) ->
	Res = exec:run_link("java -Xms1G -Xmx3G -jar minecraft_server.1.6.2.jar", Options),
	{reply, Res, State};

handle_call(Request, _From, State) ->
	io:format("Unknown Call: ~p~n", [Request]),
	{reply, ok, State}.


handle_cast(Msg, State) ->
	io:format("Unknown Cast: ~p~n", [Msg]),
	{noreply, State}.


handle_info(Info, State) ->
	io:format("Unknown Message: ~p~n", [Info]),
	{noreply, State}.


terminate(_Reason, _State) ->
	ok.


code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

