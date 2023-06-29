# Modeling Users
In Chapter 5, we ended with a stub page for creating new users.

## User model
### Database migration
Simple `users` table

| id | name | email     |
| -- | ---- | --------- |
| 1  | Tu   | tu@tu.com |

A sketch of `users` data model

|               |           |
| ------------- | --------- |
| id            | integer   |
| name          | string    |
| email         | string    |
| created_at    | datetime  |
| updated_at    | datetime  |

Generate a User model
```bash
rails generate model User name:string email:string
```
Migrate to database
```bash
rails db:migrate
```
### The model file
Located at `/app/model/`

Play with *sandbox* console:
```bash
rails console --sandbox
```
```console
> User.new
=> #<User id: nil, name: nil, email: nil, created_at: nil,
updated_at: nil>

> user = User.new(name: "Michael Hartl", email: "michael@example.com")
=> #<User id: nil, name: "Michael Hartl", email:
"michael@example.com",
created_at: nil, updated_at: nil>

> user.valid?
=> True

> user.save
(0.1ms) SAVEPOINT active_record_1
SQL (0.8ms) INSERT INTO "users" ("name", "email", "created_at",
"updated_at") VALUES (?, ?, ?, ?) [["name", "Michael Hartl"],
["email", "michael@example.com"], ["created_at", "2022-03-11
01:51:03.453035"],
["updated_at", "2022-03-11 01:51:03.453035"]]
(0.1ms) RELEASE SAVEPOINT active_record_1
=> true

> user
=>
#<User:0x00007f666efee260
 id: 1,
 name: "Michael Hartl",
 email: "michael@example.com",
 created_at: Mon, 26 Jun 2023 06:48:30.983122000 UTC +00:00,
 updated_at: Mon, 26 Jun 2023 06:48:30.983122000 UTC +00:00>

> user.name
=> "Michael Hartl"

> user.email
=> "michael@example.com"

> user.updated_at
=> Fri, 11 Mar 2022 01:51:03 UTC +00:00
```
It’s often convenient to make and save a model
in two steps as we have above, but Active Record also lets you combine
them into one step with `User.create`:
```console
> User.create(name: "A Nother", email: "another@example.org")
=>
#<User:0x00007f666c453498
 id: 2,
 name: "A Nother",
 email: "another@example.org",
 created_at: Mon, 26 Jun 2023 06:55:37.444803000 UTC +00:00,
 updated_at: Mon, 26 Jun 2023 06:55:37.444803000 UTC +00:00>
```
### Finding User object
Play with *sandbox* console
```console
> User.find(2)
=>
#<User:0x00007f666c435650
 id: 2,
 name: "A Nother",
 email: "another@example.org",
 created_at: Mon, 26 Jun 2023 06:55:37.444803000 UTC +00:00,
 updated_at: Mon, 26 Jun 2023 06:55:37.444803000 UTC +00:00>
```
### Updating User object
```rb
user.name = "New name"
user.save

user.update_attribute(:email, "new@email.com")
```

## User Validation
### Validating presence
Use `validates` method to make an attribute "cannot be empty"
```rb
class User < ApplicationRecord
  validates(:name, presence: true)
end
```
Check error message
```rb
user.errors.full_messages
```
### Validate length
Limit the length of an attribute
```rb
validates(:email, presence: true, length: { maximum: 255 })
```
### Format validation
Example: `email` need format validation
```rb
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
validates(:email, format: { with: VALID_EMAIL_REGEX })
```
Break down the `VALID_EMAIL_REGEX`
| Expression    | Meaning           |
| ------------- | ----------------- |
| /             | tart of regex     |
| \A            | match start of a string   |
| [\w+\-.]+     | at least one word character, plus, hyphen, or dot |
| @             | literal "at sign" |
| [a-z\d\-.]+   | at least one letter, digit, hyphen, or dot    |
| \.            | literal dot       |
| [a-z]+        | at least one letter   |
| \z            | match end of a string |
| /             | end of regex      |
| i             | case-insensitive  |

### Uniqueness validation
To enforce uniqueness of an attribute.
```rb
validates(:email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true)
```
The uniqueness validation is case-sensitive
```console
> user = User.create(name: "Example User", email:
"user@example.com")
> user.email.upcase
=> "USER@EXAMPLE.COM"
> duplicate_user = user.dup
>duplicate_user.email = user.email.upcase
> duplicate_user.valid?
=> true
```
Fix
```rb
uniqueness: { case_sensitive: false }
```
### Ensuring email uniqueness by downcasing the email attribute
```rb
class User < ApplicationRecord
    before_save { self.email = email.downcase }
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: true
end
```

## Database indices
In the present case, we are adding structure to an existing model, so we
need to create a migration directly using `migration` generator:
```bash
rails generate migration add_index_to_users_email
```
In `db/migrate/[timestamp]_add_index_to_users_email.rb`
```rb
class AddIndexToUsersEmail < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :email, unique: true
  end
end
```

## Adding a secure password
### A hashed password
`has_secure_password` method.

This one method adds the following functionality:
- The ability to save a securely hashed `password_digest` attribute to the
database
- A pair of virtual attributes: `password`and `password_confirmation`
- An `authenticate` method that returns the user when the password is
correct
> Requirement for `has_secure_password`: The corresponding model to have
> an attribute called `password_digest`.

> `has_secure_password` uses a state-of-the-art hash function called `bcrypt`

### Minimum password standards
```rb
validates :password, presence: true, length: { minimum: 6 }
```
### Create and authenticating User
```rb
User.create(name: "Tuslipid", email: "tuslipid@tus.com", password: "tuslipid", password_confirmation: "tuslipid")
```
```console
> user.authenticate("lmao")
false
> user.authenticate("correct pw")
#<User:0x00007f39fbeef020
 id: 4,
 name: "Tuslipid",
 email: "tuslipid@tus.com",
 created_at: Mon, 26 Jun 2023 08:35:18.469445000 UTC +00:00,
 updated_at: Mon, 26 Jun 2023 08:35:18.469445000 UTC +00:00,
 password_digest: "[FILTERED]">
```
