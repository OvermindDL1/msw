-module(logout).

-include("records.hrl").
-compile(export_all).

main() ->
	user_utils:logout(),
	wf:redirect("/").
