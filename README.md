# Spirit

Resources represented as models

## Currently Implemented

```ruby
class Bro << Spirit::Model
  attribute :name
  attribute :gender

  has_one :room, Room
end

class Room << Spirit::Model
  attribute :address
  attribute :new

  belongs_to :owner, Bro
end

bro = Bro.create(name: 'Barney')
room = Room.create(address: 'Somewhere', owner: bro)

room.owner == bro
# => true
```
