-module(dtl).

-export([render/1, render/2]).


render(Mod) -> render(Mod, []).

render(Mod, PropList) ->
	{ok, Body} = Mod:render(
		[{flash, element_flash:render()}
		%,{script, wf_script:get_script()}
		|PropList]),
	Body.