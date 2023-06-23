# Rails-flavored Ruby
This chapter explores some elements of Ruby that are important for
Rails.
## Motivation
### Built-in helpers
Example\
`stylesheet_link_tag`: include `css` for all `media` types.
```rb
# Include style.css
<%= stylesheet_link_tag "style", "data_turbo_track": "reload" %>
```
### Custom helpers
Example
```rb
<%= customHelpers(yield(:label)) %>

# ... rely on
<% provide(:label, content) %>
```
```rb
module ApplicationHelper

  def customHelpers(label=DEFAULT_VAL)
  end

end
```

## Strings and Methods
- Strings
- Objects and Message Passing
- Method definitions

## Other data sructures
- Arrays and ranges
- Blocks
- Hashes and Symbols

## CSS revisited
```rb
<%= stylesheet_link_tag "style", "data_turbo_track": "reload" %>

# This:
stylesheet_link_tag("application", "data-turbo-track": "reload")
# is the same as this:
stylesheet_link_tag "application", "data-turbo-track": "reload"
```

## Classes
- Constructors
- Class inheritance
- Modifying built-in classes
- Shortcut of getter/setter/get&set: `attr_reader`/`attr_writer`/`attr_accessor`

### A controller class
```rb
class NameController < ApplicationController

    def home
    end

    def help
    end

end
```
### An user class

