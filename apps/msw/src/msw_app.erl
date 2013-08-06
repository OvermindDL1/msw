-module(msw_app).

-behaviour(application).

%% Application callbacks
-export([
	start/0,
	start/2,
	stop/1
	]).

-define(APPS, [sasl, lager, sync, exec, crypto, ranch, cowboy, asn1, public_key, ssl, n2o, bcrypt, erlpass, eleveldb, erlcron, gproc, msw]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
	[io:format("~p -> ~p~n", [A, application:start(A)]) || A <- ?APPS].

start(_StartType, _StartArgs) ->
    msw_sup:start_link().

stop(_State) ->
    ok.
