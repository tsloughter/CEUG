{application, blog, [
	{description,  "Nitrogen Website"},
	{mod, {blog_app, []}},
  {vsn, "0.1.0"},        
  {modules, [
             blog_app,
             web_index,
             web_post,
             web_login,
             web_register
            ]},
  {registered,[blog]},        
  {applications, [kernel, stdlib, sasl, gas]}
]}.
