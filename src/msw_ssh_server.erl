-module(msw_ssh_server).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% ------------------------------------------------------------------
%% Record Definitions
%% ------------------------------------------------------------------
-record(state, {sshd}).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(_Args) ->
	{ok, Hostname} = application:get_env(ssh_server_hostname),
	{ok, Port} = application:get_env(ssh_server_port),
	lager:info("Starting SSH Server (~s) on ~p~n",
			[Hostname, Port]),
	{ok, Sshd} = ssh:daemon(Hostname, Port, [
		%{key_db, msw_ssh_server_keyapi}, % TODO: Does not work... why?
		{pwdfun, fun passwd/2},
		%{password, "testing"},
		{subsystems, []},
		%{shell, fun(User, PeerAddr)-> lager:info("Launching shell?",[]), {ok, Pid}=msw_ssh_server_shell:start(User, PeerAddr), Pid end},
		{shell, fun(User, PeerAddr) -> msw_ssh_server_shell:start(User, PeerAddr) end},
		%{failfun, fun()-> lager:info("User failed connection", []) end},
		%{connectfun, fun()-> lager:info("User connected", []) end},
		%{disconnectfun, fun()-> lager:info("User disconnected", []) end},
		{user_dir, "users/root/.ssh/"},
		{system_dir, "users/root/.ssh/"}
		]),
	ets:new(ssh_shell_cmds, [ordered_set, named_table, public, {read_concurrency, true}]),
	msw_ssh_server_shell:insert_default_shell_routines(),
	{ok, #state{sshd = Sshd}}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, #state{sshd=Sshd}) ->
	ssh:stop_daemon(Sshd),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

passwd(Test, Test) ->
	true;
passwd(_User, _Password) ->
	false.