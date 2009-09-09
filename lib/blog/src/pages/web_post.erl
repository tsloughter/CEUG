-module (web_post).
-include_lib ("nitrogen/include/wf.inc").
-compile(export_all).

main() -> 
    case wf:user() of
        undefined ->
            wf:redirect("login");
        _ ->            
            #template { file=nitrogen:get_wwwroot()++"/template.html"}
    end.

title() ->
    "CEUG Blog: New Post".

body() ->
    [#table{rows=[
                  #tablerow {cells=[#tablecell{body=[#textbox {id=title, class="textbox_input"}]}]},
                  #tablerow {cells=[#tablecell{body=[#textarea {id=post, class="textarea_input"}]}]},
                  #tablerow {cells=[#tablecell{body=[#button {id=submit, text="Submit",
                                                              postback=submit}]}]}                  
                 ]}].

event(submit) ->
    [Title] = wf:q(title),
    [Post] = wf:q(post),
    db_interface:submit_post(Title, Post),
    wf:flash("Post Saved!");
event(_) ->
    ok.
