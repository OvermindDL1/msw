-module(mcservers).

-include("records.hrl").
-compile(export_all).

main() ->
	#template{ file="./priv/templates/fivespace.html" }.

title() -> "Minecraft Server List".

body() ->
    [
    	#table{ id=mcserverlist, rows=[
    		#tablerow{ cells=[
    			#tableheader{ text="Id" },
    			#tableheader{ text="Enabled" },
    			#tableheader{ text="Name" }
    		]},
    		[#tablerow{ cells=[
    			#tablecell{ text=Server:id() },
    			#tablecell{ text=Server:enabled() },
    			#tablecell{ text=Server:name() }
    			
    		]} || Server <- boss_db:find(msw_mcserver, [])]
    	]},
		%#jqgrid{ id = server_grid,
		%	options=[
		%		{url, 'get_jqgrid_data'},
		%		{datatype, <<"json">>},
		%		{colNames, ['Id', 'Enabled', 'Name']},
		%		{colModel, [
		%			[{name, 'id'}, {index, 'id'}, {width, 55}],
		%			[{name, 'enabled'}, {index, 'enabled'}, {width, 20}],
		%			[{name, 'name'}, {index, 'name'}, {width, 100}]
		%		]},
		%		{rowNum, 10},
		%		{rowList, [10, 20, 30]},
		%		{sortname, 'id'},
		%		{viewrecords, true},
		%		{sortorder, <<"desc">>},
		%		{caption, <<"Minecraft Server List">>},
		%		{groupColumnShow, false},
		%		{loadonce, false},
		%		{scrollOffset, 0}, %% switch off scrollbar
		%		{autowidth, true} %% fill parent container on load
		%	],
		%	actions=[
		%		#jqgrid_event{trigger = jqgrid, target = jqgrid, type = ?ONDBLCLICKROW, postback = on_dblclick}
		%	]
		%},
		#br{},#br{},
		#button{ text="Defaults", postback=defaults }
	].

event(defaults) ->
	%ServerPre = msw_mcserver:new(id, "Test Server", true, term_to_binary(mcservertype_installer_0), term_to_binary([{version, <<"1.6.4-9.11.1.935">>}])),
	ServerPre = msw_mcserver:new(id, "Test Server", true, term_to_binary({mcservertype_installer_0, <<"1.6.4-9.11.1.935">>})),
	erlang:display(ServerPre:save()),
	ok;

event(Event) ->
	wf:wire(#alert { text=["Unknown Event: ", wf:to_list(Event)] }).


jqgrid_event(Event) ->
	wf:wire(#alert { text=["Unknown JQEvent: ", wf:to_list(Event)] }).
