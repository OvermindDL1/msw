-module(msw_sup).

-behaviour(supervisor).
-export([
	start_link/0,
	init/1
	]).

-compile(export_all).
-include_lib ("nitrogen_core/include/wf.hrl").
-define(APP, msw).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	%application:start(crypto),
	%application:start(nprocreg),
	%application:start(ranch),

	%% Start boss_db
	{ok, DBOptions} = application:get_env(dboptions),
	boss_db:start(DBOptions),
	%boss_cache:start(CacheOptions), % If you want cacheing with Memcached
	boss_news:start(),

	%% Start Cowboy...
	application:start(cowboy),
	{ok, BindAddress} = application:get_env(cowboy, bind_address),
	{ok, Port} = application:get_env(cowboy, port),
	{ok, ServerName} = application:get_env(cowboy, server_name),
	{ok, DocRoot} = application:get_env(cowboy, document_root),
	{ok, StaticPaths} = application:get_env(cowboy, static_paths),

	io:format("Starting Cowboy Server (~s) on ~s:~p, root: '~s'~n",
			[ServerName, BindAddress, Port, DocRoot]),

	Dispatch = init_dispatch(DocRoot, StaticPaths),
	{ok, _} = cowboy:start_http(http, 100, [{port, Port}], [
		{env, [{dispatch, Dispatch}]},
		{max_keepalive, 50}
	]),

	{ok, { {one_for_one, 5, 300}, [
		?CHILD(msw_mcservers_sup, superviser),
		?CHILD(msw_ssh_server, worker)
		]} }.

init_dispatch(DocRoot,StaticPaths) ->
	Handler = cowboy_static,
	StaticDispatches = lists:map(fun(Dir) ->
		Path = reformat_path(Dir),
		Opts = [
				{mimetypes, {fun mimetypes:path_to_mimes/2, default}}
				| localized_dir_file(DocRoot, Dir)
		],
		{Path,Handler,Opts}
	end,StaticPaths),

	%% HandlerModule will end up calling HandlerModule:handle(Req,HandlerOpts)
	HandlerModule = nitrogen_cowboy,
	HandlerOpts = [],

	%% Start Cowboy...
	%% NOTE: According to Loic, there's no way to pass the buck back to cowboy 
	%% to handle static dispatch files so we want to make sure that any large 
	%% files get caught in general by cowboy and are never passed to the nitrogen
	%% handler at all. In general, your best bet is to include the directory in
	%% the static_paths section of cowboy.config
	Dispatch = [
	    %{["/favicon.ico"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"static">>]}}, {file, "favicon.ico"}]},
	    %{["/content/[...]"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"content">>]}},
		%{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
	    %%{["/static/[...]"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"static">>]}},
		%{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
	    %{["/plugins/[...]"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"plugins">>]}},
		%{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
	    {["/get_jqgrid_data/[...]"], get_jqgrid_data, []},
	    {["/websocket"], ws_handler, []},
	    {["/jqdata"], jqdata, []},
		%% Nitrogen will handle everything that's not handled in the StaticDispatches
		{'_', StaticDispatches ++ [{'_',HandlerModule , HandlerOpts}]}
	],
	cowboy_router:compile(Dispatch).


localized_dir_file(DocRoot,Path) ->
	NewPath = case hd(Path) of
		$/ -> DocRoot ++ Path;
		_ -> DocRoot ++ "/" ++ Path
	end,
	_NewPath2 = case lists:last(Path) of
		$/ -> [{directory, NewPath}];
		_ ->
			Dir = filename:dirname(NewPath),
			File = filename:basename(NewPath),
			[
				{directory,Dir},
				{file,File}
			]
	end.

%% Ensure the paths start with /, and if a path ends with /, then add "[...]" to it
reformat_path(Path) ->
	Path2 = case hd(Path) of
		$/ -> Path;
		$\ -> Path;
		_ -> [$/|Path]
	end,
	Path3 = case lists:last(Path) of 
		$/ -> Path2 ++ "[...]";
		$\ -> Path2 ++ "[...]";
		_ -> Path2
	end,
	Path3.

%dispatch_rules() ->
%	cowboy_router:compile(
%		%% {Host, list({Path, Handler, Opts})}
%		[{'_', [
%			{["/favicon.ico"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"static">>]}}, {file, "favicon.ico"}]},
%			{["/content/[...]"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"content">>]}},
%				{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
%			{["/static/[...]"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"static">>]}},
%				{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
%			{["/plugins/[...]"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"plugins">>]}},
%				{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
%			{["/doc/[...]"], cowboy_static, [{directory, {priv_dir, ?APP, [<<"doc">>]}},
%				{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
%			{["/get_jqgrid_data/[...]"], get_jqgrid_data, []},
%			{["/websocket"], ws_handler, []},
%			{["/jqdata"], jqdata, []},
%			{'_', nitrogen_cowboy, []}
%	]}]).
