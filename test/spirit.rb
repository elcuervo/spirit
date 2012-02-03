require "cutest"
require_relative "../lib/spirit"

class User < Spirit::Model
  attribute :id
  attribute :name
  has_one :room, Room
end

class Room < Spirit::Model
  attribute :number
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

test "nested creation" do
  user = User.create(name: 'Barney', room: Room.create(number: 1))
  assert user.room.is_a?(Room)
  assert_equal 1, user.room.number
end

