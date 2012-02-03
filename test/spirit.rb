require "cutest"
require_relative "../lib/spirit"

class User < Spirit::Model
  attribute :id
  attribute :name
  has_one :room, Room
end

class Room < Spirit::Model
  attribute :number
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
  assert_equal user, user.room.owner
  assert_equal user.object_id, user.room.owner.object_id
end

