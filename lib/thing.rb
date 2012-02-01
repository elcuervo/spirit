module T
  class Collection
    include Enumerable
  end

  class Model
    @@attributes ||= Hash.new { |hash, key| hash[key] = [] }

    def initialize(attrs = {})
      @_attributes = Hash.new { |hash, key| hash[key] = get(key) }
      attrs.each { |key, value| send(:"#{key}=", value) }
    end

    def self.attribute(name)
      define_method(name) do
        @_attributes[name]
      end

      define_method(:"#{name}=") do |value|
        @_attributes[name] = value
      end

      attributes << name unless attributes.include?(name)
    end

    def self.has_one(thing)
    end

    def self.create(*args)
      new(*args)
    end

    def self.attributes
      @@attributes[self]
    end

  end
end
