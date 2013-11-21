-module(page_embeds).

-include("records.hrl").

-export([user_welcome/0
	,user_name/0
	%,user_login_logout_a/0
	,menu/0
	]).

user_welcome() ->
	case user_utils:get_logged_in_email() of
		undefined -> #template{ file="./priv/templates/loggedout.html", bindings=[], module_aliases=[]};
		_Email    -> #template{ file="./priv/templates/loggedin.html", bindings=[], module_aliases=[]}
	end.

user_name() ->
	case user_utils:get_logged_in_email() of
		undefined -> "Anonymous";
		Email     -> Email
	end.

%user_login_logout_a() ->
%	case user_utils:get_logged_in_email() of
%		undefined -> #link{ text="Login",  url="/login"  };
%		_Email    -> #link{ text="Logout", url="/logout" }
%	end.

menu() ->
	[
		#menu{ id = menu,
			options = [
				{icons, {{submenu, <<"ui-icon-circle-triangle-e">>}}},
				{position, {{my, <<"left top">>}, {at, <<"right top">>}}}
			],
			%style = "width:150px;",
			body = [
				#item{title = "Home", url="/"},
				#item{title = "MC Servers", url="/mcservers/"}
			]
		}
	].
	
