-module(user_utils).

-export([new/2
        ,new/3
        ,get/2
	,change_password/3
	,login/2
	,get_logged_in_email/0
	,logout/0
        ,create_default_user_set_if_not_existing/0
        ]).

-define(WORKFACTOR, 12).

new(Email, RawPassword) -> new(Email, RawPassword, term_to_binary([])).

new(Email, RawPassword, Permissions) ->
	Password = erlpass:hash(RawPassword, ?WORKFACTOR),
	User = msw_user:new(id, Email, Password, Permissions),
	User:save().

get(Email, RawPassword) ->
	case boss_db:find_first(msw_user, [{email, equals, Email}]) of
		undefined ->
			erlpass:hash("To use time"),
			{error, "The supplied email does not exist."};
		User -> case erlpass:match(RawPassword, User:password()) of
				false -> {error, "Incorrect Password"};
				true -> User
			end
	end.

change_password(Email, OldPassword, NewPassword) ->
	case boss_db:find_first(msw_user, [{email, equals, Email}]) of
		undefined ->
			erlpass:hash("To use time"),
			{error, "The supplied email does not exist."};
		User ->
			case erlpass:change(OldPassword, User:password(), NewPassword, ?WORKFACTOR) of
			{error, _} = Error -> Error;
			Password ->
				NewUser = User:set(password, Password),
				NewUser:save()
			end
	end.

login(Email, Password) ->
	login(get(Email, Password)).
login({error, _Msg} = Error) -> Error;
login(User) ->
	wf:user(User:email()),
	wf:session(user_perms, User:get_permissions()),
	User.

get_logged_in_email() ->
	wf:user().

logout() ->
	wf:clear_user(),
	wf:clear_roles(),
	ok.

create_default_user_set_if_not_existing() ->
	Anonymous = new("anon", ""),
	Admin = new("admin@temp.deactivateme", "testering"),
	[Anonymous, Admin].
