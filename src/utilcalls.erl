-module(utilcalls).

-include("records.hrl").
-compile(export_all).

titlearea() ->
	#template{ file="./priv/templates/titlearea.html", bindings=[], module_aliases=[]}.

fivespace() ->
	%% action triggered on layout resize event to dynamically resize grid to fill parent container
	wf:wire(wf:f("function resizeGrid(pane, $Pane, paneState) {
	jQuery(obj('~s')).jqGrid('setGridWidth', paneState.innerWidth, 'true')};", [jqgrid])),

	[
	% Main layout...
	#layout {
	    %% add menubar for navigation
	    north=#panel{id = title_win, body = titlearea()},
	    north_options = [{size, 60}, {spacing_open, 0}, {spacing_closed, 0}],

	    west=#panel{id = menu_win, body = page_embeds:menu()},
	    west_options=[{size, 200}, {spacing_open, 0}, {spacing_closed, 0}],

	    %center=#panel{id = center, body = [ #label{ text = "Center" }]},
		center=#panel{id = content_win, body = (wf:page_module()):body() },
	    %% add handler to resize grid on the layout resize, not sure how to bind
	    %% onresize event after layout creation
	    center_options=[{onresize, resizeGrid}, {triggerEventOnLoad, true}],

	    east=#panel{id = help_win, body = #template{ file=["./priv/templates/help_", wf:page_module(), ".html"], bindings=[], module_aliases=[]}},
	    east_options=[{size, 300}],
	    %%east_options=[{size, 300}, {spacing_open, 0}, {spacing_closed, 0}],

	    south=#panel{id = status_win, text = "South"},
	    south_options=[{size, 30}, {spacing_open, 0}, {spacing_closed, 0}]
	}
	].
