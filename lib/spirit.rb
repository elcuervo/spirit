module Spirit
  class LazyModel
    def initialize(name, &block)
      @name = name
      @block = block
    end

    def method_missing(method, *args)
      ::Kernel.raise(::NoMethodError, "Call to %s#%s, but not defined." % [@name, method])
    end

    def load
      @block.call
    end
  end

  class Model
    def initialize(attributes = {})
      @_attributes = {}
      @_memoized = {}

      update_attributes(attributes)
    end

    def self.const_missing(name)
      model = LazyModel.new(name) { const_get(name) }
    rescue NameError
    end

    def update_attributes(attributes)
      attributes.each do |key, value|
        send(:"#{key}=", value)
      end
    end

    def self.has_one(name, model)
      define_method(name) do
        @_memoized[name] ||= model.load.new
      end
    end

    def self.attribute(name, cast = nil)
      define_method(name) do
        @_attributes[name]
      end

      define_method(:"#{name}=") do |value|
        @_attributes[name] = value
      end

      attributes << name unless attributes.include?(name)
    end

    def self.attributes
      @attributes ||= []
    end
  end
end
