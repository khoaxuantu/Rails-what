# Following Users

Adding a social layer with following and followers...

## The relationship model
> Many to many
```
user <>--> user

# Relationship database:
user <>--> active_relationships <--<> user
```

| relationships     |           |
| ----------------- | --------- |
| id                | integer   |
| follower_id       | integer   |
| followed_id       | integer   |
| created_at        | datetime  |
| updated_at        | datetime  |

```bash
rails generate model Relationship follower_id:integer followed_id:integer
```
```rb
# app/models/user.rb
has_many(
    :active_relationships,
    class_name: "Relationship",
    foreign_key: "follower_id",
    dependent: :destroy
)
```
| Method                        | Purpose                       |
| ----------------------------- | ----------------------------- |
| active_relationship.follower  | returns the follower          |
| active_relationship.followed  | returns the followed user     |
| user.active_relationships.create(followed_id: other_user.id) | creates an active relationship associated with `user`  |
| user.active_relationships.create!(followed_id: other_user.id) | creates an active relationship associated with `user` (exception on failure) |
| user.active_relationships.build(followed_id: other_user.id) | returns a new relationship object associated with `user` |

### Relationship validations
- The following and followed `user` must exist
```rb
# app/models/relationship.rb
validates :follower_id, presence: true
validates :followed_id, presence: true
```
### Followed Users
```rb
# At app/model/user.rb
has_many(
    :following,
    through: :active_relationships,
    source: :followed
)
```
It tells the user to take the `following` from the source `followed`
(method to returns `followed_id`) in `active_relationships`
```rb
user.following.include?(other_user)
user.following.find(other_user)

# Add
user.following << other_user

# Delete
user.following.delete(other_user)
```
Utility methods:
```rb
# app/models/user.rb

# Follows a user
def follow(other_user)
    following << other_user unless self == other_user
end

# Unfollows a user
def unfollow(other_user)
    following.delete(other_user)
end

# Returns true if the current user is following the other user
def following?(other_user)
    following.include?(other_user)
end
```
### Followers
```rb
# app/models/user.rb
has_many(
    :passive_relationships,
    class_name: "Relationship",
    foreign_key: "followed_id",
    dependent: :destroy
)

has_many(
    :followers,
    through: :passive_relationships,
    source: :follower
)
```

## A Web Interface for Following Users
```rb
# config/routes.rb
resources :users do
    member do
        get :following, :followers
    end
end
resources :relationships, only: [:create, :destroy]
# => /users/:id/following
# => /users/:id/followers
```
### Stats and a Follow Form
[_stats.html.erb](../../app/views/shared/_stats.html.erb)\
[_unfollow.html.erb](../../app/views/users/_unfollow.html.erb)\
[_follow.html.erb](../../app/views/users/_follow.html.erb)\
[_follow_form.html.erb](../../app/views/users/_follow_form.html.erb)
### Following and Followers Pages
```rb
# app/controllers/users_controller.rb
before_action :login_required, only: %i[index edit update destroy following followers]

def following
    @title = I18n.t 'relationships.following'
    @pagy, @users = pagy(@user.following)
    render 'show_follow', status: :unprocessable_entity
end

def followers
    @title = I18n.t 'relationships.followers'
    @pagy, @users = pagy(@user.followers)
    render 'show_follow', status: :unprocessable_entity
end
```
[show_follow.html.erb](../../app/views/users/show_follow.html.erb)

### Follow/unfollow button
```bash
rails generate controller Relationships
```
```rb
# app/controllers/relationships_controller.rb

before_action :login_required

def create
    user = User.find(params[:followed_id])
    current_user.follow(user)
    redirect_to user
end

def destroy
    user = Relationship.find(params[:id]).followed
    current_user.unfollow(user)
    redirect_to user, status: :see_other
end
```
### A Working Follow Button with Hotwire
We only want to change parts of the page that have changed, not an entire page.

We'll use *Turbo*. Turbo works via so-called *Tubo streams* to send
small snippets of HTML directly to the page using *WebSockets*.
```rb
# app/controllers/relationships_controller.rb

def create
    ser = User.find(params[:followed_id])
    current_user.follow(user)
    respond_to do |format|
      format.html { redirect_to user }
      format.turbo_stream
    end
end

def destroy
    user = Relationship.find(params[:id]).followed
    current_user.unfollow(user)
    respond_to do |format|
      format.html { redirect_to user, status: :see_other }
      format.turbo_stream
    end
end
```
Rails activates Turbo automatically after it's installed.\
If there is nothing to respond to Turbo streams, then Rails defaults to
responding as if they were regular HTML requests.\
When the code adds lines specifically to respond to Turbo req, Rails looks for an embedded Ruby template of the form
```rb
<action>.turbo_stream.erb # <action> is the name of the corresponding action
```
At `app/views/relationships/create.turbo_stream.erb`
```erb
<%= turbo_stream.update "follow_form" do %>
  <%= render partial: "users/unfollow" %>
<% end %>

<%= turbo_stream.update "followers" do %>
  <%= @user.followers.count %>
<% end %>
```
At `app/views/relationships/destroy.turbo_stream.erb`
```erb
<%= turbo_stream.update "follow_form" do %>
  <%= render partial: "users/follow" %>
<% end %>

<%= turbo_stream.update "followers" do %>
  <%= @user.followers.count %>
<% end %>
```

## The Status Feed
To query the microposts from the followings
```rb
Micopost.where("user_id IN (?) OR user_id = ?", following_ids, id)
```
```rb
User.first.following.map(&:id).join(', ')
User.first.following_ids.join(', ')
```
### Subselects and Eager Loading
The query above doesn't scale well if a user were following several thousands
of users.

**Problems:**
1. `following_ids` pulls *all* the followed users' ids into memory, which
creates an array with the full length of the followed users array.
There should be a more efficient way to handle this and don't need to
create that array.

    **Solution**\
     Using a *subselect*. Apply SQL query to get the ids directly at the
     database view.

    Using key-value pairs in the feed;s `where` method
    ```rb
    # app/models/user.rb
    def feed
        Micropost.where(
            "user_id IN (:following_ids) OR user_id = :user_id",
            following_ids: following_ids,
            user_id: id
        )
    end
    ```
    The question mark is fine, but when we want the *same* variable inserted
    in more than one place, the second hash-based syntax is more convenient.\
    Then we change the `following_ids` to reuse `:user_id`
    ```rb
    def feed
        following_ids = "SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id"
        Micropost.where(
            "user_id IN (#{following_ids})
            OR user_id = :user_id",
            user_id: id
        )
    ```
2. Even the more efficient code above pulls out only the feed's
microposts, without the associated users. As a result, the feed partial,
which calls the micropost partial, enerates an extra databse hit to find
user corresponding to each micropost. If `N`posts then there will be
`N+1` queries...

    **Solution**\
    Using `eager loading`. Read the [blog](https://news.learnenough.com/eager-loading).\
    Eager loading involves including the users (and images) as part of
    single micropost query, so that everything needed for the feed gets pulled out at
    the same time, thus requiring only 1 database hit.

    The way to use eager loading in Rails is via a method called `includes`.
    ```rb
    Micropost.where(
            "user_id IN (#{following_ids})
            OR user_id = :user_id",
            user_id: id
    )
    .includes(:user, image_attachment: :blob)
    ```
