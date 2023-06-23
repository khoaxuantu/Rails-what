# Mostly Static Page
## Sample app setup
Generating a new sample app
```bash
cd ~/Workspace/Ruby-Tutorial/rails
rails new sample_app --skip-bundle
cd sample_app/
```
The `--skip-bundle` option skips the installation of the packages needed for
using JavaScript with Rails. We will install these packages by hand in Chapter 8.

`bundle install`\
To install and include the gems specified in the `Gemfile`.
```bash
bundle config set --local without 'production'
bundle install
```
> `--local without production` is a "remembered option", which means it will be
> included automatically the next time we run `bundle install`

Migrate the database
```rb
rails db:migrate
```

Run the test suite to verify that everything is working correctly:
```rb
rails test
```

### Hello World
```rb
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base

    def hello
        render html: "hello, world"
    end

end

# config/routes.rb
Rails.application.routes.draw do
    root "application#hello"
end
```

## Static Pages
### Generated static pages
Generate a Static Pages controller
```bash
rails generate controller StaticPages home help
```
> If you want to undo, type `rails destroy controller StaticPages home help`

The routes details:
```rb
# config/routes.rb
Rails.application.routes.draw do
    get "static_pages/home"
    get "static_pages/menu"

    root "application#hello"
end
```
The rule:
```rb
get "static_pages/home"
```
maps requests for the URL `static_pages/home` to the `home` action in
`StaticPagesController`. By using `get` we arrange for the route to
respond to a GET req.

## Getting started with testing
**TDD**

In this section, we will cover *controller test*, *model tests* will
be covered in chapter 6 and *integration test* will be covered in
chapter 7.

### First test (Green)
```rb
require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get static_pages_home_url
    assert_response :success
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
  end
end
```

### Red
TDD focuses on writing a failing test first.

Add one failing test
```rb
# Controller wasn't having about route
test "should get about" do
    get static_pages_about_url
    assert_response :success
end
```

### Testing tiles
```rb
require "test_helper"

class NameControllerTest < ActionDispatch::IntegrationTest
    test "should get api" do
    get name_api_url
    assert_response :success
    assert_select "title", "Correct title"
end
```

### A test for the root route
```rb
test "should get root" do
    get FILL_IN
    assert_response FILL_IN
end
```

## Layout and Embedded Ruby
```rb
<%= yield(:aLabel) %>

----------------------

<% provide(:aLabel, content) %>
```
```rb
<%= yield %>
```

## Advanced testing setup
### Minitest reporters
```rb
# Add to test/test_helper.rb
require "minitest/reporters"
Minitest::Reporters.use!
```
### Automated test with Guard
The `Gemfile` has already included the guard gem in our application, so
to get started we just need to initialize it then edit the`Guardfile`
```bash
bundle exec guard init
```
Once Guard is configured, you should open new terminal and run it
```bash
bundle exec guard
```

> End Chapter 3...
