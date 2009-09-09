-module (web_index).
-include_lib ("nitrogen/include/wf.inc").
-compile(export_all).

main() -> 
    #template { file=nitrogen:get_wwwroot()++"/template.html"}.

title() ->
    "CEUG Blog".

body() ->
    {ok, Posts} = db_interface:get_posts(),
    lists:map(fun([Title, Post]) ->
                          #p {body=
                              [#h1{class="title", text=Title},
                               #span{class="post", text=Post},
                               #hr{}]}
                  end, Posts).

event(_) ->
    ok.
