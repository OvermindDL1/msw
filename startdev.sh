#!/bin/sh
clear
rebar compile
#erl -mnesia dir '"./mnesia"' -pa apps/*/ebin deps/*/ebin -eval 'sync:go(), application:start(eirc), application:start(overbot).'
erl -mnesia dir '"./mnesia"' -pa ./ebin apps/*/ebin deps/*/ebin -eval 'application:start(msw).'
