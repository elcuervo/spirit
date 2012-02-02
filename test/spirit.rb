require "cutest"
require_relative "../lib/spirit"

class User < Spirit::Model
  attribute :id
  has_one :room, Room
end

class Room < Spirit::Model
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
