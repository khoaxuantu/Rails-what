# Account activation

Strategy:
1. Start users in an "unactivated" state.
2. When a user signs up, generate an activation token and corresponding activation
digest
3. Save the activation digest to the database, and then send an email to the user with
a link containing the activation token and user's email address.
4. When the user clicks the link, find the user by email address, and then authenticate
the token by comparing with the activation digest.
5. If the user is authenticated, change the status from "unactivated" to "activated"

Analogy between login, remembering, account activation, pw reset:
| Method                | find_by   | String            | Digest            | Authentication        |
| --------------------- | --------- | -------------     | -------------     | --------------------- |
| login                 | email     | password          | password_digest   | authenticate (pw)     |
| remember me           | id        | remember_token    | remember_digest   | authenticated?(:remember, token)      |
| account activation    | email     | activation_token  | activation_digest | authenticated?(:activation, token)    |
| password reset        | email     | reset_token       | reset_digest      | authenticated?(:reset, token) |

## Account Activations Resource
### Account Activations controller
```bash
rails generate controller AccountActivations
```
Adding a route for the Account Activations `edit` action
```rb
resources :account_activations, only: [:edit]
```
### Account Activations data model
We need a unique activation token for use in the activation email.
```rb
user.activation_token
```
Authenticate the user with code like
```rb
user.authenticated?(:activation, token)
```
Add a boolean attribute `activated` to the model, which will allow us to test if an
user is activated
```rb
if user.activated?
```
The model finally looks like:
|                   |           |
| ----------------- | --------- |
| id                | integer   |
| name              | string    |
| email             | string    |
| created_at        | datetime  |
| updated_at        | datetime  |
| password_digest   | string    |
| remember_digest   | string    |
| admin             | string    |
| activation_digest | string    |
| activated         | boolean   |
| activated_at      | datetime  |

```bash
rails generate migration add_activation_to_users \
> activation_digest:string activated:boolean activated_at:datetime
```
### Activation token callback
```rb
before_create :create_activation_digest
.
.
.
def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
end
```

## Account activation emails
```bash
rails generate mailer UserMailer account_activation password_reset
```
URL pattern
```rb
edit_account_activation_url(@user.activation_token, @user.email)
```
```
http://www.example.com/account_activations/q5lt38hQDc_959PVoo6b7A/edit?email = foo%40example.com
```
Update mailer views
```erb
<!-- app/views/user_mailer/account_activation.text.erb -->
Hi <%= @user.name %>,
Welcome to the Sample App! Click on the link below to activate your
account:
<%= edit_account_activation_url(@user.activation_token, email:
@user.email) %>

<!-- app/views/user_mailer/account_activation.html.erb -->
<h1>Sample App</h1>

<p>Hi <%= @user.name %>, </p>

<p>
  Welcome to the Sample App! Click on the link below to activate your
  account:
</p>

<%= link_to "Activate",
  edit_account_activation_url(@user.activation_token,
  email: @user.email) %>
```
### Preview email
```rb
# config/environments/development.rb
Rails.applcation.configure do
    .
    .
    .
    config.action_mailer.raise_delivery_errors = false

    host = 'domain.com' # In local development, use localhost:3000 instead
    # Use this on the cloud IDE.
    config.action_mailer.default_url_options = { host: host, protocol: 'https' }
    # Use this if developing on localhost.
    # config.action_mailer.default_url_options = { host: host, protocol: 'http' }
    .
    .
    .
end
```
```rb
# test/mailers/previews/user_mailer_preview.rb
def account_activation
  user = User.first
  user.activation_token = User.new_token
  UserMailer.account_activation(user)
end
```
### Update the Users `create` action
```rb
def create
  if @user.save
    UserMailer.account_activation(@user).deliver_now
    flash[:info] = "Please check your email to activate your account"
    redirect_to root_url
  else
    ...
```

## Activating the account
### Generalizing the `authenticated?` method
```rb
user = User.find_by(email: params[:email])
if user && user.authenticated?(:activation, params[:id])
```
```rb
def authenticated?(attribute, token)
  digest = self.send("{attribute}_digest")
  return false if digest.nil?
  BCrypt::Password.new(digest).is_password?(token)
end
```
### Activation `edit` action
```rb
if user && !user.activated? && user.authenticated?(:activation, params[:id])
```
If the user is authenticated according to the booleans above, we need to activate the
user and update the `activted_at` timestamp.
```rb
user.update_attribute(:activated, true)
user.update_attribute(:activated, Time.zone.now)
```
Show only mail-activated user
```rb
# app/controllers/users_controller.rb

