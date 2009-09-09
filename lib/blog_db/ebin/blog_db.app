%% This is the application resource file (.app file) for the chatyeo,
%% application.
{application, blog_db, 
  [{description, "CEUG Blog DB Backend"},
   {vsn, "0.1.0"},
   {modules, [blog_db_app,   
              blog_db_sup,   
              db_connection_server,             
              db_interface
              ]},
   {registered,[blog_db_sup, p1]},
   {applications, [kernel, stdlib, sasl, gas, mysql]},
   {mod, {chatyeo_db_app,[]}},
   {start_phases, []}]}.

