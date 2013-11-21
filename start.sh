#!/bin/sh
cd `dirname $0`

exec erl -pa $PWD/ebin -pa $PWD/deps/*/ebin -name web"@"$HOSTNAME \
    -s msw_app start -config ebin/msw
