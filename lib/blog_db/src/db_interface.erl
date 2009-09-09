%%%-------------------------------------------------------------------
%%% @author Tristan <tristan@kfgyeo>
%%% @copyright (C) 2009, Tristan
%%% @doc
%%%
%%% @end
%%% Created : 27 Aug 2009 by Tristan <tristan@kfgyeo>
%%%-------------------------------------------------------------------
-module(db_interface).

%% API
-compile(export_all).

-include_lib("nitrogen/include/wf.inc").

init() ->
    mysql:prepare(submit_post_query, 
                  <<"INSERT INTO posts (title, post, timestamp) VALUES (?, ?, now())">>),
    
    mysql:prepare(get_posts_query, 
                  <<"SELECT title, post FROM posts ORDER BY timestamp DESC LIMIT 10">>),
    
    mysql:prepare(add_user_query, 
                  <<"INSERT INTO users (username, email, fullname, password, date_joined, last_logged_in) VALUES (?, ?, ?, PASSWORD(?), DATE(NOW()), NOW())">>),

    mysql:prepare(validate_user_query, 
                  <<"SELECT 1 FROM users WHERE (username=? OR email=?) AND password=PASSWORD(?)">>),

    mysql:prepare(update_last_logged_in_query, 
                  <<"UPDATE users SET last_logged_in=datetime()">>),

    mysql:prepare(is_username_used_query, 
                  <<"SELECT 1 FROM users WHERE username=?">>),
    
    mysql:prepare(is_email_used_query, 
                  <<"SELECT 1 FROM users WHERE email_address=?">>),
    
    mysql:prepare(get_email_address_query, 
                  <<"SELECT email FROM users WHERE username=?">>),

    mysql:prepare(get_user_id_query, 
                  <<"SELECT id FROM users WHERE username=? OR anon_username=?">>).

submit_post(Title, Post) ->
    mysql:transaction(p1,
                      fun() ->
                              mysql:execute(p1, submit_post_query, [Title, Post])
                      end).

get_posts() ->
    {atomic, {data, MySQLResults}}
        = mysql:transaction(p1,
                            fun() ->
                                    mysql:execute(p1, get_posts_query, [])
                            end),
    mysql:get_result_rows(MySQLResults).

add_user(Username, FullName, Email, Password) ->
    case mysql:transaction(p1,
                      fun() ->
                              mysql:execute(p1, add_user_query, [Username, Email, FullName, Password])
                      end) of
        {atomic, {updated, _}} ->
            ok;
        {aborted, {{error, {mysql_result,[],[],0,0, Reason}}, _}} ->
            {aborted, Reason}
    end.

validate_user(Username, Password) ->
    case mysql:transaction(p1,
                           fun() ->
                                   mysql:execute(p1, validate_user_query, [Username, Username, Password])
                           end) of
        {atomic, {data, MySQLResults}} ->
            Rows = mysql:get_result_rows(MySQLResults),
            if 
                length (Rows) == 1 -> 
                    {ok, valid};
                true -> 
                    {error, false}
            end;
        _ ->
            {error, false}
    end.    

update_last_logged_in(Username) ->
    mysql:transaction(p1,
                      fun() ->
                              mysql:execute(p1, update_last_logged_query, [Username])
                      end).

delete_user(Username) ->
    mysql:transaction(p1,
                      fun() ->
                              mysql:execute(p1, delete_user_query, [Username])
                      end).

is_username_used(Username) ->
    case mysql:transaction(p1,
                           fun() ->
                                   mysql:execute(p1, is_username_used_query, [Username])
                           end) of
        {atomic, {data, MySQLResults}} ->
            Rows = mysql:get_result_rows(MySQLResults),
            if 
                length (Rows) == 1 ->            
                    false;
                true -> 
                    true
            end;
        _ ->
            true
    end.

is_email_used(Email) ->
    case mysql:transaction(p1,
                           fun() ->
                                   mysql:execute(p1, is_email_used_query, [Email])
                           end) of
        {atomic, {data, MySQLResults}} -> 
            Rows = mysql:get_result_rows(MySQLResults),
            if
                length (Rows) == 1 -> 
                    false;
                true -> 
                    true
            end;
        _ ->
            true
    end.

get_email_address(Username) ->
    case mysql:transaction(p1,
                           fun() ->
                                   mysql:execute(p1, get_email_address_query, [Username])
                           end) of
        {atomic, {data, MySQLResults}} ->
            Rows = mysql:get_result_rows(MySQLResults),
            if
                length(Rows) == 1 ->
                   {ok, hd(hd(Rows))};
                true ->
                    {error, unknown_user}
            end;
        _ ->
            {error, unknown_user}
    end.
 
get_user_id (User) ->
    {data, {mysql_result, _, [[UserID]|_], _, _, _}} = 
        mysql:execute(p1, get_user_id_query, [User, User]),
    {ok, UserID}.
