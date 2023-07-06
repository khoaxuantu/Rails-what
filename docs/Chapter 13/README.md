# User Microposts
User microposts are short messages associated with a particular user.

We'll contruct the Micropost data model, associate it with the User model using
`has_many` and `belongs_to` method, and then making the forms and partials needed
to manipulate and display the results.

### A Micropost Model
| microposts    |           |
| ------------- | --------- |
| id            | integer   |
| content       | text      |
| user_id       | integer   |
| created_at    | datetime  |
| updated_at    | datetime  |

```bash
rails generate model Micropost content:text user:references
```
### Micropost Validations
```rb
# app/models/micropost.rb
class Micropost < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates(
    :content,
    presence: true,
    length: { maximum: 140 }
  )
end
```
### User/Micropost Associations
`belongs_to` relationship
```
micropost --belongs_to--> micropost.user
```
`has_many` (one-to-many) relationship: one user to many posts
```
micropost <---<> user
```
Instead of
```rb
Micropost.create
Micropost.create!
Micropost.new
```
we have
```rb
user.microposts.create
user.microposts.create!
user.microposts.build
```
| Method            | Purpose                                           |
| ----------------- | ------------------------------------------------- |
| micropost.user    | returns the User object associated with the micropost |
| user.microposts   | returns a collection of the user's microposts     |
| user.microposts.create(arg) | creates a micropost associated with `user` |
| user.microposts.create!(arg) | creates a micropost associated with `user` (exception on failure) |
| user.microposts.build(arg) | returns a new Micropost object associated with `user` |
| user.microposts.find_by(id: 1) | finds the micropost with id `1` and`user_id` equal to `user.id` |

At `app/models/micropost.rb`
```rb
belongs_to :user
```
At `app/models/user.rb`
```rb
has_many :microposts
```

### Micropost Refinements
**Default Scope**\
By default, the `user.microposts` makes no guarantees about the order of the posts,
but we want the microposts to come out in reverse order of when they were created.

We'll use a Rails method called `default_scope`, which among other things can be
used to se the default order in which elements are retrieved from the database.
To enforce a particular order, we'll include the `order` argument in it.
```rb
order(:created_at)
order('created_at DESC')
order(created_at: :desc)
```
At `app/models/micropost.rb`
```rb
default_scope -> { order(created_at: :desc) }
```

**Dependendt: Destroy**\
Ensuring that a user's microposts are destroyed along with the user
```rb
# app/model/user.rb
has_many :microposts, dependent: :destroy
```

## Showing Microposts
```bash
rails generate controller Microposts
```
```rb
# app/controller/users_controller.rb
def show
    @pagy, @posts = pagy(@user.microposts)
    redirect_to root_url and return unless @user.activated?
end
```
At `app/views/microposts/_micropost.html.erb`
```erb
<li id="micropost-<%= micropost.id %>">
    <%= link_to gravatar_for(micropost.user, size: 50), micropost.user %>
    <span class="user">
        <%= link_to micropost.user.name, micropost.user %>
    </span>
    <span class="content">
        <%= micropost.content %>
    </span>
    <span class="timestamp">
        Posted <%= time_ago_in_words(micropost.created_at) %> ago.
    </span>
</li>
```
At `app/views/users/show.html.erb`
```erb
<div class="col-md-8">
    <% if @user.microposts.any? %>
        <h3>Microposts (<%= @user.microposts.count %>)</h3>
        <ol class="microposts">
            <%= render @microposts %>
        </ol>
        <%== pagy_nav(@pagy) %>
    <% end %>
</div>
```

## Manipulating Microposts
Create and delete posts

| HTTP req method   | URL           | Action| Named route               |
| ----------------- | ------------- | ----- | ------------------------- |
| POST              | /microposts   | create| microposts_path           |
| DELETE            | /microposts/1 | destroy | microposts_path(micropost) |

```rb
resources :microposts, only: [:create, :destroy]
```
### Micropost Access Control
- Both the `create` and `destroy` actions must require users to be logged in.

### Creating Microposts
At `app/controllers/microposts_controller.rb`
```rb
def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = I18n.t 'micropost.create_successful'
      redirect_to root_url
    else
      render 'static_pages/home', status: :unprocessable_entity
    end
end

def micropost_params
    params.require(:micropost).permit(:content)
end
```
Add microposts creation to the Home page `/`
```erb
<% if logged_in? %>
    <div class="row">
        <aside class="col-md-4">
            <section class="user_info">
                <%= render 'shared/user_info' %>
            </section>
            <section class="micropost_form">
                <%= render 'shared/micropost_form' %>
            </section>
        </aside>
    </div>
<% else %>
.
.
.
```
`app/views/shared/_micropost_form.html.erb`
```erb
<%= form_with(model: @micropost) do |f| %>
    <%= render 'shared/error_messages', object: f.object %>
    <div class="field">
        <%= f.text_area :content, placeholder: "Compose new micropost..." %>
    </div>
    <%= f.submit "Post", class: "btn btn-primary" %>
<% end %>
```
`app/views/shared/_user_info.html.erb`
```erb
<%= link_to gravatar_for(current_user, size: 50), current_user %>
<h1><%= current_user.name %></h1>
<span><%= link_to "view my profile", current_user %></span>
<span>
    <%= pluralize(current_user.microposts.count, "micropost") %>
</span>
```
### A Proto-Feed
Define a `feed` method at `User` model
```rb
# Defines a proto-feed
def feed
    Micropost.where("user_id = ?", id)
end
```
The home controller will call the `feed` method
```rb
# app/controllers/static_pages_controller.rb
def home
    if (logged_in?)
      @user = current_user
      @micropost = current_user.microposts.build
      @pagy, @feed_items = pagy(current_user.feed)
    end
end
```
At home view `/`
```erb
<div class="col-md-8">
    <h3>Micropost Feed</h3>
    <%= render 'shared/feed' %>
</div>
```
`app/views/shared/_feed.html.erb`
```erb
<% if @feed_items.any? %>
    <ol class="microposts">
    <%= render @feed_items %>
    </ol>
    <%== pagy_nav(@pagy) %>
<% end %>
```
We need to add a `@feed_items` to micropost's `create` action to prevent fail
submissions crashing the program.
```rb
# app/controllers/microposts_controller.rb
def create
    if @micropost.save
        ...
    else
        @pagy, @feed_items = pagy(current_user.feed)
        ...
    end
end
```
This time, changing page in pagingation will raise an error because the `create`
action is in the Microposts controller. We fix it by adding `:request_path` to
the `pagy()`
```rb
@pagy, @pagy, @feed_items = pagy(current_user.feed, request_path: root_url)
```

### Destroying Microposts
- The user who create a micropost can delete this micropost

At `app/controllers/microposts_controller.rb`
```rb
before_action :correct_user, only: [:destroy]

def destroy
    @micropost.destroy
    flash[:success] = I18n.t 'micropost.delete_successful'
    if request.referrer.nil?
      redirect_to root_url, status: :see_other
    else
      redirect_to request.referrer, status: :see_other
    end
end

def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url, status: :see_other if @micropost.nil?
end
```

In the redirect, because users can delete microposts from either the profile page
or the Home page, it's convenient to redirect back to the *referring* page. So we
use `request.referrer` method.

## Micropost Images
### Basic Image Upload
- Use a built-in feature called Active Storage.
```
rails active_storage:install
```
This command generates a database migration that creates a data model for storing
attached files
```rb
# app/models/micropost.rb
has_one_attached :image
```
At `app/views/shared/_micropost_form.html.erb`
```erb
<span class="image">
    <%= f.file_field :image %>
</span>
```
Finally, we need to update the Microposts controller to add the image to the newly
created micropost object.
```rb
# app/controllers/microposts_controller.rb
def create
    ...
    @micropost.image.attach(params[:micropost][:image])
    ...
end
```
Once the image has beed uploaded, we can render the associated `micropost.image`
using `image_tag`.\
At `app/views/microposts/_micropost.html.erb`
```erb
<%= image_tag micropost_image if micropost.image.attached? %>
```
### Image Validation
```rb
gem "active_storage_validations"
```
[Gem docs](https://github.com/igorkasyanchuk/active_storage_validations)

At `app/models/micropost.rb`
```rb
validates(
    :image,
    content_type: {
      in: %w[image/jpeg image/gif image/png],
      message: I18n.t('micropost.image_type_validate')
    },
    size: {
      less_than: 5.megabytes,
      message: I18n.t('micropost.image_size_validate')
    }
)
```
We can add 2 client-side checks o nthe uploaded image size and format.
```js
// app/javascript/custom/image_upload.js

// Prevent uploading of big images.
document.addEventListener("turbo:load", function() {
    document.addEventListener("change", function(event) {
        let image_upload = document.querySelector('#micropost_image');
        const size_in_megabytes = image_upload.files[0].size/1024/1024;
        if (size_in_megabytes > 5) {
            alert("Maximum file size is 5MB. Please choose a smaller file.");
            image_upload.value = "";
        }
    });
});
```
We can filter the input for valid format
```erb
<%= f.file_field :image, accept: "image/jpeg,image/gif,image/png" %>
```

### Image Resizing
```rb
gem "image_processing"
```
[Gem docs](https://github.com/janko/image_processing)

Using MiniMagick for processing images
```rb
# config/application.rb
    config.active_storage.variant_processor = :mini_magick
```
`resize_to_limit`
```rb
# app/models/micropost.rb

# Set a size limit to 500x500 pixels
has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
end
```
Use the resized display image.\
At `app/views/microposts/_micropost.html.erb`
```erb
<%= image_tag micropost.image if micropost.image.attached? %>
    <%= image_tag micropost.image.variant(:display) %>
<% end %>
```
