# Advanced Login

## Remember me
### Remember token and digest
> The previous chapter's session disappears when the user closes their browser

We'll take the first step toward persistent sessions by generating a
*remember token* appropriate for creating permanent cookies using the
`cookies` method, together with a secure *remember digest* for
authenticating those tokens.

Plan:
1. Create a random string as a remember token.
2. Place the token in the browser cookies.
3. Save the hash digest of the token to the database.
4. Place an encrypted version of the user's id in the browser cookies.
5. When presented with a cookie containing a persistent user id, find the
user in the database using the given id, and verify that the remember token
cookie matches.

Add the `remember_digest` attribute to the User model
```bash
rails generate migrationadd_remmeber_digest_to_users remember_digest:string
```

In `app/models/user.rb`

Add a method for generating tokens
```rb
def self.new_token
    SecureRandom.urlsafe_base64
end
```

Add a digest method to hash the remember token

The password is created using bcrypt (via `has_secure_password`), so we'll
need to create the fixture password using the same method.

```rb
def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
      BCrypt::Engine::MIN_COST : BCrypt::Engine.const

    BCrypt::Password.create(string, cost: cost)
end
```
Add a remember method to remember user to the databse
```rb
def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
end
```
### Login with remembering
Make a persistent session by creating a cookie
```rb
cookies[:remember_token] = {
    value: remember_token,
    expires: 20.years.from_now.utc
}

cookies.permanent[:remember_token] = remember_token # Same as above
```
Store id to cookie
```rb
cookies[:user_id] = user.id
cookies.encrypted[:user_id] = user.id # better
cookies.permanent.encrypted[:user_id] = user.id # to be paired with remember token
```
We can retrieve user by
```rb
User.find_by(id: cookies.encrypted[:user_id])
```
To compare the `remember_token` in cookie with the `remember_digest` in
the databse
```rb
BCrypt::Password.new(remember_digest).is_password?(remember_token)
```
### Forgetting users
At User model
```rb
update_attribute(:remember_digest, nil)
```
Delete cookies
```rb
cookies.delete(:user_id)
cookies.delete(:remember_token)
```
### Some checknotes
- Multiple browsers logged in case: Be careful when users hit log out.
- `remember_digest` must exist in database to be compared with `remember_token`

## "Remember me" checkbox
Get value from checkbox form
```rb
params[:session][:remember_me]
```
- `1`: The box is checked
- `0`: The box isn't checked
```rb
if params[:session][:remember_me] == '1'
    remember(user)
else
    forget(user)
end
```
