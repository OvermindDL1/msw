-module(msw_mcserver_sup).

-behaviour(supervisor).
-export([
	start_link/0,
	init/1
	]).

-compile(export_all).

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
	{ok, { {simple_one_for_one, 5, 10}, []} }.
