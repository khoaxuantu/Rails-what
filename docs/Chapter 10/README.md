# Updating, Showing, and Deleting Users

## Updating Users
- Create new edit form like signup form
- Update new action in users controller
```rb
def edit
    @user = User.find(params[:id])
end

def update
    @user = User.find(params[:id])
    if @user.update(user_params)
        # Handle a successful update
        flash[:success] = "Profile updated"
        redirect_to @user
    else
        render 'edit', status: :bad_request
    end
end
```
- We may not update password, so we have to add `allow_nil` property to
`validate` in user model.
```rb
validates(
    :password,
    presence: true,
    length: { minimum: 6 },
    allow_nil: true
)
```

## Authorization
- Some actions need to be logged in first (eg. login_required)
- We'll add a `login_required` method to `before_action` at user controller
```rb
before_action :login_required, only: [:edit, :update]
```
```rb
def login_required
    unless logged_in?
      flash[:danger] = "Login required."
      redirect_to login_url, status: :unauthorized
    end
end
```
- We have to assure that we're editing correct user i.e yourself. So for
`/users/{:other_id}/edit` and `PUT /users/{:other_id}` we should not access and be redirected to root path:
```rb
before_action :correct_user, only: [:edit, :update]

def correct_user
    if params[:id].to_i != current_user.id
      redirect_to(root_url, status: :bad_request)
    end
end
```
- At final convention, we'll define `current_user?` boolean method for use
in the `correct_user`:
```rb
unless params[:id].to_i != current_user.id

to

unless current_user?(@user)
```
We will make some changes to the sessions helper:
- Define `session_token` method at user model, which returns a session token
```rb
# Returns a session token to prevent session hijacking
# We reuse the remember digest for convenience
def session_token
    remember_digest || remember
end

# At remember method, we need to return the remember_digest
def remember
    ...
    remember_digest
end
```
- Add `:session_token` to session to guard against session replay attacks
```rb
def log_in
    # Guard against session replay attacks
    # See https://bit.ly/33UvK0w for more information
    session[:session_token] = user.session_token;
end
```
- Integrate `:session_token` with `current_user` method
```rb
if session[:user_id]
    user = User.find_by(id: session[:user_id])
    if user && session[:session_token] == user.session_token
        @current_user = user
    end
elsif cookies.encrypted[:user_id]
    ...
```
- Define the `current_user?` method
```rb
def current_user?(user_id)
    user = User.find_by(id: user_id)
    user && user == current_user
end
```

## Showing All Users
### Users index
```rb
before_action :login_required, only: [:index, :edit, :update]

def index
    @users = User.all
end
```
### Sample users
We need to create enough users to make a decent users index, to do this conveniently, we'll add
the `Fake` gem to `Gemfile`.

```rb
gem 'faker'
```
We seed the database with sample users at `db/seeds.rb` then start seed
```bash
rails db:seed
```
### Pagination
To show a number of users, there are several pagination methods available in Rails. We'll use one
of the simplest and most robust, called `will_paginate`
```rb
gem "will_paginate"
gem "bootstrap-will_paginate"
```
In `app/views/users/index.html.erb
```erb
<%= will_paginate %>
<ul class="users">
    <% @users.each do |user| %>
        <li>
            <%= gravatar_for user, size: 50 %>
            <%= link_to user.name, user %>
        </li>
    <% end %>
</ul>
<%= will_paginate %>
```

## Deleting users
### Administrative users
```bash
rails generate migration add_admin_to_users admin:boolean
```
- Turn on an boolean attribute
```rb
obj.toggle!(:boolean_attr)
```
- Add destroy action to users controller
```rb
def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
end
```
