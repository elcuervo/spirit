require "cutest"
require "mock_server"
require_relative "../lib/spirit"

extend MockServer::Methods

mock_server {
  post "/users" do
    request.body
  end

  post "/rooms" do
    request.body
  end
}

class User < Spirit::Model
  site      "http://localhost:4000"
  resource  "users"

  attribute :id
  attribute :name

  has_one :room, Room
  has_many :friends, User
end

class Room < Spirit::Model
  site      "http://localhost:4000"
  resource  "rooms"

  attribute  :number
  belongs_to :owner, User
end

test "attributes" do
  assert User.attributes.include?(:id)

  user = User.new
  user.id = 1

  assert_equal 1, user.id
end

test "has_one" do
  user = User.new
  assert user.room.is_a?(Room)
end

test "create" do
  user = User.create(name: 'Barney')
  assert_equal 'Barney', user.name
end

test "model relations" do
  user = User.create(name: 'Barney', room: Room.create(number: 1))
  assert user.room.is_a?(Room)
  assert_equal 1, user.room.number
end

test "has_many" do
  user = User.create(name: 'Forever Alone')
  assert_equal [], user.friends

  user = User.create(name: 'Barney')
  user.friends.create(name: 'Ted')
  user.friends.create(name: 'Robin')
  user.friends.create(name: 'Marshall')
  user.friends.create(name: 'Lilly')

  assert_equal 4, user.friends.length
  assert user.friends.first.is_a?(User)
end
