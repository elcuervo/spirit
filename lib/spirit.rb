module Spirit
  class Model

    class Collection
      include Enumerable
    end

    class Wrapper < BasicObject
    end

    attr_accessor :url, :resource
    @@attributes ||= Hash.new { |hash, key| hash[key] = [] }

    def initialize(attrs = {})
      @_attributes = Hash.new { |hash, key| hash[key] = get(key) }
      attrs.each { |key, value| send(:"#{key}=", value) }
    end

    def create
      self
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

    def self.has_one(model)
    end

    def self.has_many(model)
    end

    def self.belongs_to(model)
    end

    def self.const_missing(name)
      wrapper = Wrapper.new(name) { const_get(name) }

      begin
        super(name)
      rescue NameError; end

      wrapper
    end

    def self.url(url)
      @url = url
    end

    def self.resource(resource)
      @resource = resource
    end

    def self.create(*args)
      model = new(*args)
      model.create
      model
    end

    def self.attributes
      @@attributes[self]
    end

    def self.relations
      @@relations[self]
    end

  end
end
