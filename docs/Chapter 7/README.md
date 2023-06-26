# Sign Up

## Showing Users
### Debug and Rails environment
```erb
<%= debug(params) if Rails.env.development? %>
```
### A Users resource
Make a user profile page, following REST.

Get the routing for `/user/1` to work by adding a single line to our routes
file `config/routes.rb`
```rb
resource :users
```
RESTful routes table for Users resource
| HTTP request method   | URL           | Action    | Named route           | Purpose |
| --------------------- | ------------- | --------- | --------------------- | ------- |
| GET                   | /users        | index     | users_path            | page to list all users    |
| GET                   | /users/1      | show      | user_path(user)       | page to show user |
| GET                   | /users/new    | new       | new_user_path         | page to make a new user (signup)  |
| POST                  | /users        | create    | users_path            | create a new user
| GET                   | /users/1/edit | edit      | edit_user_path(user)  | page to edit user with id 1   |
| PATCH (PUT)           | /users/1      | update    | user_path(user)       | update user   |
| DELETE                | /users/1      | destroy   | user_path(user)       | delete user   |

**Show user in html.erb**
```rb
def show
    @user = User.find(params[:id])
end
```
```erb
<%= @user.name %>, <%= @user.email %>
```
### Debugger
```rb
def show
    @user = User.find(params[:id])
    debugger
end
```
The Rails console server shows an `rdbg` prompt
```console
(rdbg)
(rdbg) @user
(rdbg) @user.name
```

### A Gravatar Image and a Sidebar
`Gravatar`: globally recognized avatar - a free service that allows users
to upload images and associate them with email addresses they control

`gravatar_for`: a custom helper function to return a Gravatar image for a given user.
```erb
<!-- app/views/users/show.html.erb -->
<% provide(:title, @user.name) %>
<h1>
    <%= gravatar_for @user %>
    <%= @user.name %>
</h1>
```
```rb
# app/helpers/users_helper.rb

def gravatar_for(user)
    gravatarId = Digest::MD5::hexdigest(user.email.downcase)
    gravatarUrl = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatarUrl, alt: user.name, class: "gravatar")
end
```
Add a sizebar to the user `show` view
```erb
<!-- app/views/users/show.html.erb -->

<% provide(:title, @user.name) %>
<div class="row">
    <aside class="col-md-4">
        <section class="user_info">
            <h1>
                <%= gravatar_for @user %>
                <%= @user.name %>
            </h1>
        </section>
    </aside>
</div>
```
