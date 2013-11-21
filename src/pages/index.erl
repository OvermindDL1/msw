-module(index).

-include("records.hrl").
-compile(export_all).

main() ->
	#template{ file="./priv/templates/fivespace.html", bindings=[], module_aliases=[]}.

title() -> "Minecraft Server Wrapper".

body() ->
	%% action triggered on layout resize event to dynamically resize grid to fill parent container
	%wf:wire(wf:f("function resizeGrid(pane, $Pane, paneState) {
	%	jQuery(obj('~s')).jqGrid('setGridWidth', paneState.innerWidth, 'true')};", [jqgrid])),

	[
	].

event(Event) ->
	wf:wire(#alert { text=["Unknown Event: ", wf:to_list(Event)] }).
