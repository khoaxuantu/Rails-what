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
