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
## Db migration:
```bash
rails db:migrate

rails db:rollback
rails db:migrate VERSION=0

rails db:migrate:reset

rails db:seed
```
## Routing
```rb
root "controller_name#action_name"

get 'controller_name/api'

get '/name', to: 'controller#action'

resource :controller
resources :controller
```
```rb
redirect_to name_url
redirect_to dynamic_url(:dynamicParams)

# Redirect to the referrer page
if request.referrer.nil?
  redirect_to root_url
else
  redirect_to request.referrer
end
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

- `form_with`
[API ref](https://api.rubyonrails.org/v7.0.6/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
```erb
<%= form_with(model: @user) do |f| %>
<% end %>
```

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
- `Scope`\
Scoping allow you to specify commonly-used queries which can be referenced as method
calls on the association objects or models. With these scopes, you can use every
method previously covered such as `where`, `joins`, and `includes`.\
[Reference](https://guides.rubyonrails.org/active_record_querying.html#scopes)

### Active Record Associations
- `belongs_to`, `has_many`: Chapter 13

[Reference](https://guides.rubyonrails.org/association_basics.html)

### Model scope
`default_scopes`

[Reference](https://www.rubyguides.com/2019/10/scopes-in-ruby-on-rails/)

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

## Rails HTTP Status Code
[Reference](http://www.railsstatuscodes.com/)

## Form
- Chapter 7

## Session
```rb
session[:user_id]

reset_session
```

## Rails Internationalization (I18n) API
<details>

### How it works
#### Overall architecture
- The public API of the i18n framework - a Ruby module with public methods that define how the library works
- A default backend (which is intentionally named Simple backend) that implements these methods
#### The public I18n API
The most important methods
```rb
translate # Lookup text translation
localize # Localize Date and Time objects to local formats
```
Alias...
```rb
I18n.t 'store.title'
I18n.l Time.now
```
There are also attribute readers and writers for the following attributes:
```rb
load_path                 # Announce your custom translation files
locale                    # Get and set the current locale
default_locale            # Get and set the default locale
available_locales         # Permitted locales available for the application
enforce_available_locales # Enforce locale permission (true or false)
exception_handler         # Use a different exception_handler
backend                   # Use a different backend
```
### Setup
#### Configure the i18n Module
The default `en.yml`
```yaml
en:
    hello: "Hello world"
```
This means, that in the :en locale, the key hello will map to the Hello world string. Every string inside Rails is internationalized in this way.


</details>

## Caching
- By default, caching is only enabled in your production environment. You can play
around with caching locally by running `rails dev:cache`, or by setting
`config.action_controller.perform_caching` to `true` in `config/environments/development.rb`

`Fragment caching`\
It allows a fragment of view logic to be wrapped in a cache block and served out of
the cache store when the next req comes in.
```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```
When your application receives its first request to this page, Rails will write a new
cache entry with a unique key
```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```
If you want to cach a fragment under certain conditions
```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```
[More ref](https://guides.rubyonrails.org/caching_with_rails.html)

## Mailer
```bash
rails generate mailer MailerName serviceA serviceB
```
`ApplicationMailer < ActionMailer::base`
- `default()`\
Set default values for all emails sent fromthis mailer\
[API ref](https://api.rubyonrails.org/v7.0.5.1/classes/ActionMailer/Base.html#method-c-default)
```rb
default from: 'mymail@example.com'
```
- `mail()`\
Creates the actual email message.\
[API ref](https://api.rubyonrails.org/v7.0.5.1/classes/ActionMailer/Base.html#method-i-mail)
```rb
mail(to: "sth@example.com", subject: "Bla bla bla")
```
- `deliver_now()`\
Deliver an email directly.
- `deliver_later()`\
Enqueue the email to be delivered through Active Job. When the job runs it will send
the email using `deliver_now()`\
[API ref](https://api.rubyonrails.org/v7.0.6/classes/ActionMailer/MessageDelivery.html)

## Active storage
- For media storage...

[Reference](https://edgeguides.rubyonrails.org/active_storage_overview.html)\
[Blog: Using active storage in rails](https://pragmaticstudio.com/tutorials/using-active-storage-in-rails)

For models:
- `has_one_attached`: Associate an uploaded file with a given model
- `has_many_attached`: Associate many updloaded files with a given model

For controllers:
- `attach`
