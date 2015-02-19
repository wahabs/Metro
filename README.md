# Metro
A server-side Model-View-Controller framework inspired by [Ruby on Rails.](http://rubyonrails.org/) Utilizes a
server built with [WEBrick](http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html)
and a Controller Base class built with [Rails Active Support.](http://guides.rubyonrails.org/active_support_core_extensions.html)

Incorporates its own Object Relational Mapping System, called [Caboose.](https://github.com/wahabs/Caboose)

Metro has much of Rails' MVC functionality, including:
* Handling HTTP requests and responses
* Storing sessions and route parameters
* Rendering view templates
* Defining URL helpers such as `link_to` and `button_to`
* Storing the [FlashHash.](http://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html)
