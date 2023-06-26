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
For db migration:
```bash
rails db:migrate

rails db:rollback
rails db:migrate VERSION=0
```
## Routing
```rb
root "controller_name#action_name"

get 'controller_name/api'
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
