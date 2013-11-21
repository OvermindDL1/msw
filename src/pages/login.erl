-module(login).

-include("records.hrl").
-compile(export_all).

main() ->
	case user_utils:get_logged_in_email() of
		undefined -> #template{ file="./priv/templates/fivespace.html", bindings=[], module_aliases=[]};
		_Email -> wf:redirect_from_login("/")
	end.

title() -> "Login".

body() -> Body = [#flash{},
	#sigma_form{data=[], fields=[
		{email, "E-Mail"},
		{password, "Password", password}
	]},
	#button{id=loginButton, text="Login", postback=login, handle_invalid=true, on_invalid=#alert{text="Validation failed"}},
	#button{id=defaultsButton, text="Defaults", postback=defaults}
	],

	wf:wire(loginButton, email, #validate { validators =[
		#is_required{text="Required."},
		#is_email{text="Please enter a valid email address."}
	]}),

	wf:wire(loginButton, password, #validate { validators =[
		#is_required{text="Required."},
		#min_length { length=8, text="Password must be at least 8 characters long." }
	]}),

	wf:wire(defaultsButton, #event { type=click, actions=#effect { effect=pulsate } }),

	Body.


event(login) ->
	%wf:wire(#alert { text="Login?" });
	Email = wf:q(email),
	Password = wf:q(password),
	case user_utils:login(Email, Password) of
		{error, Msg} -> wf:flash(Msg); % TODO: Remove this Msg bit later with a generic invalid username or password...
		_User ->
			wf:redirect_from_login("/")
	end;

event(defaults) ->
	%User = msw_user:new(id, "overminddl1@gmail.com", "testering"),
	%case User:save() of
	case user_utils:create_default_user_set_if_not_existing() of
		[{error, _}|_] -> wf:wire(#alert { text="Default Test User is already created" });
		_ -> wf:wire(#alert { text="Created Default Test User" })
	end.
