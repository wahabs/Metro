![Logo](/bin/images/logo.png?raw=true)

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


## Controller

### [Router][router]
Two classes are defined in `router.rb`. A `Route` object matches a URL (e.g. `/users/:id`), to its corresponding controller (e.g. `UsersController`) and what method to run within that controller (e.g. `update`). Given an HTTPRequest, a `Router` determines which `Route` matches the requested URL. Once found, the `Route`'s controller is instantiated, and the appropriate method is run.

### [Session][session]
A Session instance takes in an HTTP Request, finds the cookie for the application, and deserializes it into a hash accessible by ControllerBase. `Session#store_session` serializes the hash into JSON, saves it to a new cookie, and adds it to the HTTP Response's cookies.

### [Params][params]
The Params class is used to merge params from the query string, POST body, and/or route params into
a hash accessible by ControllerBase.

### [URLHelper][url-helper]
Defines helper methods that receive some string input and/or options and generate corresponding HTML snippets.

### [Flash][flash]
Defines a special hash that allows preservation of data after a controller action
(i.e. after the controller instance has been discarded). The data is stored in a cookie, which expires after a subsequent controller action. The developer can alternatively store data in `flash.now`, which will only be available in the view currently being rendered by the `render` method.

### [ControllerBase][controller-base]
Defines the parent class for controllers and includes the classes above. Each controller is initialized with an HTTP response and
request, along with any route params. The primary methods are:
* `redirect_to(url)`: Sets the response header as the `url` and the status code to 302 (Found). Stores any sessions and/or Flashes.
* `render(template_name)`: Instantiates an [ERB](http://ruby-doc.org/stdlib-2.2.0/libdoc/erb/rdoc/ERB.html) analagous to the controller, binding
any variables passed in. Calls `render_content` to create an HTML view.
* `render_content(content, type)`: Populates the response with content, sets the response's content type to the given type, and raises an error if the developer tries to double render.


## Model

See the documentation for [Caboose.](https://github.com/wahabs/Caboose)



[router]: ./lib/controller/router.rb
[session]: ./lib/controller/session.rb
[params]: ./lib/controller/params.rb
[url-helper]: ./lib/controller/url_helper.rb
[controller-base]: ./lib/controller/controller_base.rb
[flash]: ./lib/controller/flash.rb
