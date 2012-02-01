require './lib/thing'

class User < T::Model
  attribute :name
end

a = User.create(name: 'pepe')
puts a.name
