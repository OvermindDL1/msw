-module(msw_mcserver,
	[Id
	,Name::string()
	,Enabled::boolean()
	,ServerType::binary() % Module call
	%ServerTypeArgs::binary() % Arguments passed to ServerType on every call in to it
	%PropAllowFlight::boolean(),
	%PropAllowNether::boolean(),
	%PropAnnouncePlayerAchievements::boolean(),
	%PropDifficulty::integer(),
	%PropEnableQuery::boolean(),
	%PropEnableRCon::boolean(),
	%PropEnableCommandBlock::boolean(),
	%PropForceGamemode::boolean(),
	%PropGamemode::integer(),
	%PropGenerateStructures
	]).

%-has({msw_mcserver_properties, 1}).

-export([before_create/0]).

-export(
	[getServerType/0
	,setServerType/1
	%,getServerTypeArgs/0
	%,setServerTypeArgs/1
	]).

before_create() ->
	%case boss_db:find(msw_mcserver, [name = name()]) of
	%	[] -> ok;
	%	_ -> {error, "Server name already exists."}
	%end.
	ok.

getServerType() ->
	binary_to_term(server_type(), [safe]).

setServerType(Module) -> %when is_atom(Module) ->
	set(server_type, term_to_binary(Module)).

%getServerTypeArgs() ->
%	binary_to_term(server_type_args(), [safe]).
%
%setServerTypeArgs(ModuleArgs) ->
%	set(server_type_args, term_to_binary(ModuleArgs)).

