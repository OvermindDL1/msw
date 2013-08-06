-module(msw_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

-define(APP, msw_app).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	{ok, Port} = application:get_env(port),
	{ok, Workers} = application:get_env(workers),
	{ok, { {one_for_one, 5, 10}, [
			%% Name, NbAcceptors, TransOpts, ProtoOpts
		{webserver, {cowboy, start_http, [webserver, Workers, [{port, Port}], [{env, [{dispatch, dispatch_rules()}]}]]}, permanent, 5000, supervisor, [cowboy]}
		]} }.



dispatch_rules() ->
	cowboy_router:compile(
	%% {URIHost, [{URIPath, Handler, Opts}]}
		[{'_', [
			{["/static/n2o/[...]"], cowboy_static,
				[{directory, iolist_to_binary([code:lib_dir(n2o_scripts), <<"/n2o">>])}]},
			{["/static/[...]"], cowboy_static,
				[{directory, {priv_dir, ?APP, [<<"static">>]}},
					{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
			{"/rest/:bucket", n2o_rest, []},
			{"/rest/:bucket/:key", n2o_rest, []},
			{"/rest/:bucket/:key/[...]", n2o_rest, []},
			{["/ws/[...]"], bullet_handler, [{handler, n2o_bullet}]},
			{'_', n2o_cowboy, []}
			]}]).
