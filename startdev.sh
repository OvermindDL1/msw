#!/bin/sh
clear
rebar compile
#erl -mnesia dir '"./mnesia"' -pa apps/*/ebin deps/*/ebin -eval 'sync:go(), application:start(eirc), application:start(overbot).'
#erl -mnesia dir '"./mnesia"' -pa apps/*/ebin deps/*/ebin -eval '
#lager:start(),
#sync:go(),
#[application:start(A) || A <- [asn1, crypto, public_key, ssl, ranch, cowboy, sasl, nitrogen_core, msw]].'

cd `dirname $0`

erl -pa $PWD/apps/*/ebin -pa $PWD/deps/*/ebin -name web"@"$HOSTNAME -s msw_app start -config dev
