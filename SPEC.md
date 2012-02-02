# Spirit

Spirit attemps to become an alternative to ActiveResource but as lightweight as
possible.

Eg.

```ruby
class User < Spirit::Model
  resource '/users'

  attribute :id
  attribute :name
end

user = User.create(name: 'Barney')
# -> POST /users
# -> {name: 'Barney'}
#
# <- 201
# <- Content-Location: http://localhost:3000/users/1
# -> GET /users/1
# {id: 1, name: 'Barney'}

user.id
# 1
```
