-module(msw_ssh_server_keyapi).

-behaviour(ssh_server_key_api).

-export([host_key/2, is_auth_key/3]).


host_key(Algorithm, DaemonOptions) ->
	io:format("~nAlgorithm: ~p~nDaemonOptions: ~p~n~n", [Algorithm, DaemonOptions]),
	{ok, "blah"}.


is_auth_key(Key, User, DaemonOptions) ->
	io:format("~nKey: ~p~nUser: ~p~nDaemonOptions: ~p~n~n", [Key, User, DaemonOptions]),
	true.
