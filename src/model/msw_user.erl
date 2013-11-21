-module(msw_user, [
	Id,
	Email::string(),
	Password::binary(),
	Permissions::binary()
	]).

%-compile(export_all).

-export([before_create/0]).

-export([change_password/2
	,get_permissions/0
	,set_permissions/0
        ]).

before_create() ->
	%[{fun() -> [] =:= boss_db:find(msw_user, [email = email()]) end, "Email already exists."}].
	case boss_db:find(msw_user, [email = email()]) of
		[] -> ok;
		_ -> {error, "Email already exists."}
	end.

change_password(OldPassword, NewPassword) ->
	user_utils:change_password(Email, OldPassword, NewPassword).

get_permissions() ->
	ok.

set_permissions() ->
	ok.
