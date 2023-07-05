# Password reset

## Password reset resource
```bash
rails generate controller PasswordResets new edit --no-test-framework
```
```rb
resources :password_resets, only: [:new, :create, :edit, :update]
```
| HTTP req method   | URL                   | Action    | Named routed          |
| ----------------- | --------------------- | --------- | --------------------- |
| GET               | /password_resets/new  | new       | new_password_resets_path |
| POST              | /password_resets      | create    | password_resets_path  |
| GET               | /password_resets/\<token>/edit | edit | edit_password_reset_url (token) |
| PATCH             | /password_resets/\<token> | update | password_reset_path (token) |

### New Password Resets
`User` model
|               |           |
| ------------- | --------- |
| reset_digest  | string    |
| reset_sent_at | datetime  |

```bash
rails generate migration add_reset_to_users reset_digest:string reset_sent_at:datetime
```
### Password Reset `create` action
```rb
def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
        @user.create_reset_digest
        @user.send_password_reset_email
        flash[:info] = I18n.t 'flash.password_reset_email_sent'
        redirect_to root_url
    else
        flash.now[:danger] = I18n.t 'flash.email_not_found'
        render 'new', status: :unprocessable_entity
    end
end
```
At `User` model
```rb
def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
end

def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
end
```

## Password Reset Emails
```rb
# app/mailers/user_mailer.rb
def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
end
```

## Resetting the password
### Reset `edit` action
Password reset emails contain links of the following form
```
https://example.com/password_resets/3BdBrXeQZSWqcxHA/edit?
email=foo%40bar.com
```
To get these links to work, we need a form for resetting password.\
At `app/views/password_resets/edit.html.erb`
```erb
<% provide(:title, 'Reset password') %>
<h1>Reset password</h1>
<div class="row">
    <div class="col-md-6 col-md-offset-3">
    <%= form_with(model: @user, url: password_reset_path(params[:id])) do |f| %>
        <%= render 'shared/error_messages' %>
        <%= hidden_field_tag :email, @user.email %>

        <%= f.label :password %>
        <%= f.password_field :password, class: 'form-control' %>

        <%= f.label :password_confirmation, "Confirmation" %>
        <%= f.password_field :password_confirmation, class: 'form-control' %>

        <%= f.submit "Update password", class: "btn btn-primary" %>
    <% end %>
    </div>
</div>
```
> hidden_field_tag instead of f.hidden_field because the reset link puts the email
> in `params[:email]`, whereas the latter would put it in `params[:user][:email]`

To get the form to render, we need to define an `@user` variable in the Password
Resets controller's `edit` action
```rb
before_action :get_user, only: [:edit, :update]
before_action :valid_user, only: [:edit, :update]
.
.
.
def edit
end
.
.
.
private

    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
```
### Updating the reset
The `edit` method for Password Resets is a form, which must therefore submit to a
corresponding `update` action. To define this `update` action, we need to consider
4 cases:
1. An expired password reset.
2. A failed update due to an invalid password.
3. A failed update (which initially looks "successful") due to an empty pw and
confirmation.
4. A successful update

At `app/controllers/password_resets_controller.rb`
```rb
before_action :check_expiration, only: [:edit, :update]

def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty.")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)
      reset_session
      log_in @user
      flash[:success] = I18n.t 'flash.password_reset_success'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
end

def user_params
      params.require(:user).permit(:password, :password_confirmation)
end

# Checks expiration of reset token
def check_expiration
    if @user.password_reset_expired?
        flash[:danger] = I18n.t 'flash.password_reset_expired'
        redirect_to new_password_reset_url
    end
end
```

At `app/model/user.rb`
```rb
# Returns true if a password reset has expired.
def password_reset_expired?
    reset_sent_at < 2.hours.ago
end
```
