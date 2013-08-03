#!/bin/sh
clear
rebar compile
#erl -mnesia dir '"./mnesia"' -pa apps/*/ebin deps/*/ebin -eval 'sync:go(), application:start(eirc), application:start(overbot).'
erl -mnesia dir '"./mnesia"' -pa apps/*/ebin deps/*/ebin -eval '
lager:start(),
application:start(asn1),
application:start(crypto),
application:start(public_key),
application:start(ssl),
application:start(ranch),
application:start(cowboy),
application:start(msw).
'
