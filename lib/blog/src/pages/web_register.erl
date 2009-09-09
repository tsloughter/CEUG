%%% This file is part of beerenthusiasts.
%%% 
%%% beerenthusiasts is free software: you can redistribute it and/or modify
%%% it under the terms of the GNU Affero General Public License as published by
%%% the Free Software Foundation, either version 3 of the License, or
%%% (at your option) any later version.
%%% 
%%% beerenthusiasts is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU Affero General Public License for more details.
%%% 
%%% You should have received a copy of the GNU Affero General Public License
%%% along with beerenthusiasts.  If not, see <http://www.gnu.org/licenses/>.

-module (web_register).
-include_lib ("nitrogen/include/wf.inc").
-compile(export_all).

main() ->
    wf:wire(submit, username, #validate { attach_to=username, validators=[#is_required { text="Required." }] }),
    wf:wire(submit, username, #validate { attach_to=username, validators=[#custom { text="Username already registered.", function=(fun (X, Y) -> is_username_used (X, Y) end) }] }),
    wf:wire(submit, username, #validate { attach_to=username, validators=[#custom { text="Error: No spaces allowed in username.", function=(fun (X, Y) -> check_username (X, Y) end) }] }),
    wf:wire(submit, username, #validate { attach_to=username, validators=[#min_length { text="Error: Username must be at least 3 characters.", length=3 }] }),
    wf:wire(submit, email_address, #validate { attach_to=email_address, validators=[#is_required { text="Required." }] }),
    wf:wire(submit, email_address, #validate { attach_to=email_address, validators=[#is_email { text="Required: Proper email address." }] }),
    wf:wire(submit, email_address, #validate { attach_to=email_address, validators=[#custom { text="Email address already registered.", function=(fun (X, Y) -> is_email_used (X, Y) end) }] }),
    wf:wire(submit, pass, #validate { attach_to=pass2, validators=[#confirm_password { text="Error: Passwords do not match", password=pass2 }] }),
    wf:wire(submit, pass, #validate { attach_to=pass, validators=[#min_length { text="Error: Passwords must be at least 8 characters.", length=8 }] }),
    
    Header = nitrogen:get_wwwroot()++"/template.html",    
    #template { file=Header }.

title() -> "Chatyeo".

body() -> 
    Cell1 = #tablecell { body = ["Register",
                                 #br{}] },
    Cell2a = #tablecell { body = ["Username: "] },
    Cell2b = #tablecell { body = [#textbox { id=username }] },
    Cell3a = #tablecell { body = ["Email Address: "] },
    Cell3b = #tablecell { body = [#textbox { id=email_address }] },

    Cell4a = #tablecell { body = ["Password: "] },
    Cell4b = #tablecell { body = [#password { id=pass }] },
    Cell5a = #tablecell { body = ["Retype Password: "] },
    Cell5b = #tablecell { body = [#password { id=pass2 }] },
   
    Row1 =  #tablerow {cells = [Cell1] },
    Row2 =  #tablerow {cells = [Cell2a,Cell2b] },
    Row3 =  #tablerow {cells = [Cell3a,Cell3b] },
    Row4 =  #tablerow {cells = [Cell4a,Cell4b] },
    Row5 =  #tablerow {cells = [Cell5a,Cell5b] },

    [#table {rows=[Row1, Row2, Row3, Row4, Row5]},
     #button { id=submit, text="Register", postback=register },
     #br{},
     "Already Registered? ",
     #link { text="Login Here", url="login" },
     #br{},
     #flash { id=flash },
     #panel { id=test }].

event (register) ->
    Pass = hd(wf:q(pass)),
    if
        Pass == "temp4now" ->
            wf:flash ("Error: that password is not allowable.");
        true ->
            case db_interface:add_user (hd(wf:q(username)), "Mr. Nobody", hd(wf:q(email_address)), hd(wf:q(pass))) of
                ok ->            
                    wf:redirect("login");
                {aborted, Reason} ->
                    wf:flash (io_lib:format("Error: ~p", [Reason]))
            end
    end;

event (_) -> 
    ok.

is_username_used (_, _) ->
    db_interface:is_username_used (hd(wf:q(username))).

is_email_used (_, _) ->
    db_interface:is_email_used (hd(wf:q(email_address))).

check_username (_, _) ->
    case string:chr (hd(wf:q(username)), $ ) of
        0 ->
            true;
        _ ->
            false
    end.
