ERL       ?= erl
ERLC       = erlc
EBIN_DIRS := $(wildcard deps/*/ebin)
#APPS      := $(shell dir apps)

.PHONY: rel deps

all: deps plugins compile copy-static

first-run: all
	mkdir -p users/root/.ssh
	@([ -e users/root/.ssh/id_rsa ] || echo && echo "Creating SSH server private/public keys"&&echo)
	@([ -e users/root/.ssh/id_rsa ] || ssh-keygen -t rsa -N "" -f users/root/.ssh/id_rsa)

quick-run:
	erl -pa ${PWD}/ebin -pa ${PWD}/deps/*/ebin -name msw_testing"@"`hostname` -s msw_app start -config ebin/msw

run: all quick-run

compile:
	mkdir -p ebin
	rebar compile

deps:
	rebar get-deps

clean:
	rebar clean

clean-deps: clean
	rebar delete-deps

fullclean: clean clean-deps
	rm -rf users

test: all
	rebar skip_deps=true eunit

doc:
	rebar doc skip_deps=true

plugins:
	@(export PATH=`pwd`/`echo erts-*/bin`:$$PATH;escript do-plugins.escript)

copy-static:
	@(cp -r deps/nitrogen_core/www/* priv/static/nitrogen/)
	@(cp -R deps/nitrogen_elements/static/* priv/static/plugins/)

testing:
	@(echo blah)