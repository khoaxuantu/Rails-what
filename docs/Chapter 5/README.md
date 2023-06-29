# Filling the layout

## Adding some structures
- In this section, add some structure to the layout and give it some minimal styling with CSS.
- [Bootstrap](https://getbootstrap.com/)
### Site navigation
Update the site layout file `application.html.erb` with additional HTML structure.

Add navigation link in layout:
```erb
<li><%= link_to "Home", '#' %></li>
<li><%= link_to "Help", '#' %></li>
<li><%= link_to "Log in", '#' %></li>
```
### Bootstrap and custom CSS
```rb
gem "bootstrap-sass"
```
```bash
bundle install
```
Create a custom SCSS file
```bash
touch app/assets/stylesheets/custom.scss
```
Inside the `custom.scss` use `@import` function to include Bootstrap. Then add some custom CSS to the file.
```scss
@import "bootstrap-sprockets";
@import "bootstrap";
```
### Partials
Beside layout, We can split chunks of code using **Partials**.

In `app/views/layouts/application.html.erb`
```erb
<head>
    ...Some tags
    <%= render 'layouts/shim' %>
</head>
<body>
    <%= render 'layouts/header' %>
    ...Some tags
</body>
```

## Sass and the Asset pipeline
### The Asset pipeline
**Asset directories**
- `app/assets`: specific to the present application
- `lib/assets`: for libraries written by your dev team
- `vendor/assets`: from 3rd-party vendor

**Manifest Files**
- The manifest file for app-specific CSS: `app/assets/stylesheets/application.css`. The key lines are the CSS comments which used by
Sprockets to include the proper files
```erb
/*
.
.
.
*= require_tree .
*= require_self
*/
```

## Layout Links
```erb
<%= link_to "About", about_path %>
```
- `name_path` -> `/name`
- `name_url` -> `https://example.com/name`
### Rails routes
Define shorter path
```rb
# Initially
get 'static_pages/home'

# Now
get "/home", to: "static_pages#help"
```

## User Signup: A first step
### Usert controller
```bash
rails generate controller Users new
```
### Signup URL
```rb
get '/signup', to: 'users#new'
```
At `app/views/users/new.html.erb`
```erb
<% provide(:title, 'Sign up') %>
<h1>Sign up</h1>
<p>This will be a signup page for new users.</p>
```
