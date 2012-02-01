require './lib/spirit'

class Post < Spirit::Model
  belongs_to User
end

class User < Spirit::Model
  url 'http://localhost:3000'
  resource 'users'
  attribute :name
  has_many Post
end

a = User.create(name: 'pepe')
puts a.name
