# Rails syntax notes
## Get started
```bash
rails new app_name
```
## Some rails shortcut
| Full command      | Shortcut  |
| ----------------- | --------- |
| rails server      | rails s   |
| rails console     | rails c   |
| rails generate    | rails g   |
| rails test        | rails t   |
| bundle install    | bundle    |

## Undoing things
```bash
rails destroy
```
```bash
rails generate controller StaticPages home help
rails destroy controller StaticPages home help

rails generate model User name:string email:string
rails destroy model User
```
For db migration:
```bash
rails db:migrate

rails db:rollback
rails db:migrate VERSION=0
```
## Routing
```rb
root "controller_name#action_name"

get 'controller_name/api'
```

## Testing
- Controller test - Chapter 3
- Model test - Chapter 6
- Integration test - Chapter 7

## Rails console
```bash
rails console
Loading development environment (Rails 7.0.5)
irb(main):001:0>
```

## html.erb tag
- `stylesheet_link_tag`
```erb
 <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
 ```
- `link_to`
```erb
<li><%= link_to "Home", '#' %></li>
<li><%= link_to "Help", '#' %></li>
<li><%= link_to "Log in", '#' %></li>
```
- `image_tag`
```erb
image_tag("rails.svg", alt: "Rails logo", width: "200")
```
- `render`
```erb
<%= render 'layouts/shim' %>
```
It will look for `app/views/layouts/_shim.html.erb`

## Model handler (interact with database)
Let's say we have a model `User`. The syntax below will be transformed
to SQL queries (like Django).
```rb
# Insert
user = User.new(...)
user.save

user1 = User.create(...)

user.valid?
user1.valid?

# Query
User.find(id)
User.find_by(valid_properties)
User.first
User.all # to a list []

# Update
user.name = "New name"
user.save

user.update_attribute(:email, "new@email.com")

# Count
User.count
```
## Debug at `html.erb`
```erb
 <%= debug(params) if Rails.env.development? %>
```

## Debug at Rails server console
Controller code
```rb
...code
debugger
...code
```
Console
```console
(rdbg)
(rdbg) @user
(rdbg) @user.name
```

