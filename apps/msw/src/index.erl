-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").

main() -> #dtl{file = "index", app=msw, bindings=[
	{title, title()},
	{body, body()}
	]}.

title() -> <<"Testing Title">>.

body() -> [
	#span{ body=io_lib:format("'/index?x=' is ~p",[wf:qs(<<"x">>)]) }
	].
