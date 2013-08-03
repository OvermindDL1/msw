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
	{ok, { {one_for_one, 5, 10}, [
			%% Name, NbAcceptors, TransOpts, ProtoOpts
		{webserver, {cowboy, start_http, [webserver, 100, [{port, 8000}], [{env, [{dispatch, dispatch_rules()}]}]]}}
		]} }.



dispatch_rules() ->
	cowboy_router:compile(
	%% {URIHost, [{URIPath, Handler, Opts}]}
		[{'_', [
			{["/static/[...]"], cowboy_static,
				[{directory, {priv_dir, ?APP, [<<"static">>]}},
					{mimetypes, {fun mimetypes:path_to_mimes/2, default}}]},
			{["/ws/[...]"], n2o_websocket, []},
			{'_', n2o_cowboy, []}
			]}]).
