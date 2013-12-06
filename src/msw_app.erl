-module(msw_app).

-behaviour(application).
-export([
	start/0,
	start/2,
	stop/1
	]).

-define(APPS, 
	[compiler
	,syntax_tools
	,goldrush
	,lager
	,sasl
	,gproc
	,nprocreg
	,sync
	,crypto
	,ranch
	,cowboy
	,bcrypt
	,asn1
	,public_key
	,ssh
	,msw
	]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

%% to start manually from console with start.sh
start() ->
	[io:format("Starting: ~p -> ~p~n", [A, application:start(A)]) || A <- ?APPS].

start(_StartType, _StartArgs) ->
	msw_sup:start_link().

stop(_State) ->
	ok.
