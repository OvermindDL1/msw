-module(msw_ssh_server_shell).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start/2, insert_default_shell_routines/0, shell_loop/2]).

%% ------------------------------------------------------------------
%% shell Function Exports
%% ------------------------------------------------------------------

-export(
	[unknown_cli/2,unknown_cli/3
	,cli_help/2,cli_help/3
	,cli_exit/2,cli_exit/3
	]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start(User, PeerAddr) ->
	spawn(fun() ->
		io:setopts([{expand_fun, fun(Bef) -> expand(Bef) end}]),
		lager:info("SSH: User ~p joined from: ~p", [User, PeerAddr]),
		io:format("Enter command\n"),
		put(user, User),
		put(peer_addr, PeerAddr),
		shell_loop(User, PeerAddr)
	end).

%% ------------------------------------------------------------------
%% io shell Function Definitions
%% ------------------------------------------------------------------

shell_loop(User, PeerAddr) ->
	% Read
	Line = io:get_line("MSW> "),
	% Eval
	Result = eval_cli(User, PeerAddr, Line),
	% Print
	io:format("---> ~p\n", [Result]),
	case Result of
		exit -> exit(normal);
		% Loop
		_ -> shell_loop(User, PeerAddr)
	end.


%%% evaluate a command line
eval_cli(User, PeerAddr, Line) when is_list(Line) ->
	CmdLen = string:cspan(Line, " \n"),
	Command = string:substr(Line, 1, CmdLen),
	Argument = string:strip(string:strip(string:substr(Line, CmdLen+1)), right, $\n),
	{Module, Proc, State} = command_to_function(Command),
	lager:debug("SSH Command call: ~p", [{{Module, Proc, State, Argument}, User, PeerAddr}]),
	Res = case catch apply(Module, Proc, [State, Argument]) of
		{'EXIT', {undef, [Error|_Rest]}} -> {error, {does_not_exist_but_it_is_registered, Error}};
		{'EXIT', Error} -> {runtime_error, Error}; % Incorrect argument count or does not exist
		Result -> Result
	end,
	lager:info("SSH Command call: ~p", [{{Module, Proc, State, Argument}, User, PeerAddr, Res}]),
	Res;
eval_cli(User, PeerAddr, {error, interrupted}) ->
	lager:warning("SSH:eval_cli:interrupted: ~p", [{User, PeerAddr}]),
	interrupted;
eval_cli(User, PeerAddr, Line) ->
	lager:warning("SSH:eval_cli:error: ~p", [{User, PeerAddr, Line}]),
	{parse_error, Line}.


%%% translate a command to a function
command_to_function(Command) ->
	case ets:lookup(ssh_shell_cmds, Command) of
		[] -> {?MODULE, unknown_cli, Command};
		[{_Command, ModTuple, _Help}] -> ModTuple
	end.

%% the longest common prefix of two strings
common_prefix([C | R1], [C | R2], Acc) ->
	common_prefix(R1, R2, [C | Acc]);
common_prefix(_, _, Acc) ->
	lists:reverse(Acc).

%% longest prefix in a list, given a prefix
longest_prefix(List, Prefix) ->
	case [A || {A, _, _} <- List, lists:prefix(Prefix, A)] of
		[] -> {none, List};
		[S | Rest] ->
			NewPrefix0 =
			lists:foldl(fun(A, P) ->
				common_prefix(A, P, [])
				end, S, Rest),
			NewPrefix = nthtail(length(Prefix), NewPrefix0),
			{prefix, NewPrefix, [S | Rest]}
	end.

%%% our expand function (called when the user presses TAB)
%%% input: a reversed list with the row to left of the cursor
%%% output: {yes|no, Expansion, ListofPossibleMatches}
%%% where the atom no yields a beep
%%% Expansion is a string inserted at the cursor
%%% List... is a list that will be printed
%%% Here we beep on prefixes that don't match and when the command
%%% filled in
expand([$  | _]) ->
	{no, "", []};
expand(RevBefore) ->    
	Before = lists:reverse(RevBefore),
	Routines = ets:foldr(fun(Elem, Acc)-> [Elem|Acc] end, [], ssh_shell_cmds),
	case longest_prefix(Routines, Before) of
		{prefix, P, [_]} -> {yes, P ++ " ", []};
		{prefix, "", M} -> {yes, "", M};
		{prefix, P, _M} -> {yes, P, []};
		{none, _M} -> {no, "", []}
	end.

%%% nthtail as in lists, but no badarg if n > the length of list
nthtail(0, A) -> A;
nthtail(N, [_ | A]) -> nthtail(N-1, A);
nthtail(_, _) -> [].

unknown_cli(Command, Argument) ->
	{error, {does_not_exist, {Command, Argument}}}.
unknown_cli(_InformationType, Command, Argument) ->
	{error, {does_not_exist, {Command, Argument}}}.


insert_default_shell_routines() ->
	ets:insert(ssh_shell_cmds,
		[{"help", {msw_ssh_server_shell, cli_help, []},       "[<str> [<str>]]       help text"}
		,{"exit", {msw_ssh_server_shell, cli_exit, []},       "                      exit application"}
		%,{"crash", {msw_ssh_server_shell, cli_crash, []},     "            crash the cli"}
		%,{"factors", {msw_ssh_server_shell, cli_factors, []}, "<int>       prime factors of <int>"}
		%,{"gcd", {msw_ssh_server_shell, cli_gcd, []},         "<int> <int> greatest common divisor"}
		]).


%% ------------------------------------------------------------------
%% Default Shell Function Definitions
%% ------------------------------------------------------------------
cli_help(_State, "") ->
	io:format("MSW Shell Help:~n~s", [ets:foldr(fun({Cmd, _ModTuple, Help}, Acc)-> [[Cmd, " ", Help, $\n]|Acc] end, [], ssh_shell_cmds)]),
	ok;
cli_help(_State, Line) ->
	CmdLen = string:cspan(Line, " \n"),
	Command = string:substr(Line, 1, CmdLen),
	Argument = string:strip(string:strip(string:substr(Line, CmdLen+1)), right, $\n),
	{Module, Proc, State} = command_to_function(Command),
	case catch apply(Module, Proc, [help, State, Argument]) of
		{'EXIT', _Error} -> {error, {has_no_extended_help, Command}}; % Incorrect argument count or does not exist
		Result -> Result
	end.

cli_help(help, _State, "help help"++_Rest) ->
	io:format("The MSW Help recursion!~n", []);
cli_help(help, _State, "help"++_Rest) ->
	io:format("The MSW Help command called on itself reports this.~n", []);
cli_help(help, _State, "") ->
	io:format("The MSW Help command reports each registered command with its short-help text.~n", []);
cli_help(help, _State, _Line) ->
	io:format("The MSW Help command called on a command (with optional arguments) will report back the extended help of the command (specialized to the arguments if applicable) if the help exists.~n", []).


cli_exit(_State, _Args) ->
	exit.

cli_exit(help, _State, _Args) ->
	io:format("Ends and disconnects your/this connection.~n", []).