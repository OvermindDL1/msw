#!/bin/sh
clear
rebar compile
#erl -mnesia dir '"./mnesia"' -pa apps/*/ebin deps/*/ebin -eval 'sync:go(), application:start(eirc), application:start(overbot).'
erl -mnesia dir '"./mnesia"' -pa apps/*/ebin deps/*/ebin -eval '
application:start(asn1),
application:start(crypto),
application:start(ssl),
application:start(public_key),
application:start(ranch),
application:start(cowboy),
application:start(msw).
'
