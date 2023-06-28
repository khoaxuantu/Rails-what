# Basic Login

## Sessions
### Sessions Controller
```bash
rails generate controller Sessions new
```
Add `/login`, `/logout` routes
```rb
get '/login', to: 'sessions#new'
post '/login', to: 'sessions#create'
delete '/logout', to: 'sessions#destroy'
```
Update appropriate controller's actions and views

```erb
form_with(url: login_path, scope: :session)
```

```
#<ActionController::Parameters
{"authenticity_token"=>"…",
"session" =>#<ActionController::Parameters
            {"email"=>"user@example.com",
            "password"=>"foobar"} permitted: false>,
            "commit"=>"Log in",
            "controller"=>"sessions",
            "action"=>"create"} permitted: false>
```
### Authenticate user
```rb
if user && user.authenticate(params[:session][:password])
    # Handle log in
else
    # Return error
end
```
### Add flash message
We can add
```rb
flash[:danger] = 'Invalid email/password combination'
```
But it isn't quite right, if we redirect to a different route after getting
the flash message, it is till there.

Fix this issue by
```rb
flash.now[:danger] = 'Invalid email/password combination'
```

## Logging in
Include the Sessions helper module into the Application controller
```rb
class ApplicationController < ActionController::Base
    include SessionsHelper
end
```
### `log_in()` method
```rb
# app/helpers/session_helper.rb
def log_in(user)
    session[:user_id] = user.id
end
```
> Because temporary cookies created using the session method are
> automatically encrypted, the code is secure.
### Current user
We'll define `current_user` method

In `html.erb`
```erb
<%= current_user %>
```
In controller
```rb
redirect_to current_user
```

```rb
# app/helpers/session_helper.rb
def current_user
    if session[:user_id]
        User.find(id: session[:user_id])
    end
end
```
To prevent hitting the database multiple times
```rb
if @current_user.nil?
    @current_user = User.find(id: session[:user_id])
else
    @current_user
end

or

@current_user = @current_user || User.find(id: session[:user_id])

or

@current_user ||= User.find(id: session[:user_id])
```
### Changing layout links
Add `logged_in` helper function
```rb
# app/helpers/session_helper.rb
def logged_in?
    !current_user.nil?
end
```
```erb
<% if logged_in? %>
    # Links for logged-in users
<% else %>
    # Links for non-logged-in-users
<% end %>
```
### Menu toggle
```bash
rails importmap:install turbo:install stimulus:install
```

## Logging out
```rb
session.delete(:user_id)
```
Better technique
```rb
# app/helpers/session_helper.rb
def log_out
    reset_session
    @current_user = nil
end

# app/controllers/session_controller.rb
def destroy
    log_out
    redirect_to root_url
end
```
