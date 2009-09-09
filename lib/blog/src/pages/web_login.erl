-module (web_login).
-include_lib ("nitrogen/include/wf.inc").
-compile(export_all).

main() ->  
    case wf:user() of
        undefined -> 
            #template { file=nitrogen:get_wwwroot()++"/template.html" };
        _ ->             
            wf:redirect("post")
    end.

title() -> "CEUG Blog".
headline() -> "Validation". 

body() -> 
    Cell1 = #tablecell { body = ["Login",
                                 #br{}] },
    Cell2a = #tablecell { body = ["Username: "] },
    Cell2b = #tablecell { body = [#textbox { id=username, postback=login }] },
    Cell3a = #tablecell { body = ["Password: "] },
    Cell3b = #tablecell { body = [#password { id=pass, postback=login }] },
   
    Row1 =  #tablerow {cells = [Cell1] },
    Row2 =  #tablerow {cells = [Cell2a,Cell2b] },
    Row3 =  #tablerow {cells = [Cell3a,Cell3b] },

    Body = [#table {rows=[Row1, Row2, Row3]},
            #button { id=submit, text="Login", postback=login }],
     
    wf:wire(submit, username, #validate { validators=[
                                                      #is_required { text="Required." }
                                                     ]}),
    
    wf:render(Body).

event (login) ->
    Username = hd(wf:q(username)),
    Password = hd(wf:q(pass)),
    
    case db_interface:validate_user(Username, Password) of
        {ok, valid} ->
            wf:user(Username),   
            wf:redirect("post");
        {error, _Reason} ->
            wf:flash ("Incorrect")
    end;

event (_) -> 
    ok.
