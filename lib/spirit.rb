module Spirit
  # Internal: Used for lazy evaluation of the model.
  #           This is the magic behind the asignation of relations when they are
  #           not defined yet.
  #
  # Examples
  #
  #   model = LazyModel.new(Test)
  #   require 'test'
  #   model.load
  #   # => Test
  #
  # Returns a lazy loaded model
  class LazyModel
    # Public: Initializes the LazyModel
    #
    # name - The Symbol of the model.
    def initialize(name)
      @name = name
    end

    # Internal: Raises an error for the missing method or the missing class.
    def method_missing(method, *args)
      ::Kernel.raise(::NoMethodError, "Call to %s#%s, but not defined." % [@name, method])
    end

    # Public: Loads the lazy-loaded model
    def load
      ::Kernel.const_get(@name)
    end
  end

  # Public: TODO
  #         Use is throght extension
  #
  # Returns a Spirit::Model
  class Model
    # Public: Initializes a Spirit::Model
    #
    # attributes - The Hash of the attributes of the model
    def initialize(attributes = {})
      @_attributes = {}
      @_memoized = {}

      update_attributes(attributes)
    end

    # Internal: Magically constructs a LazyModel for future evaluation.
    #
    # name - The Symbol of the class to be lazy loaded
    def self.const_missing(name)
      model = LazyModel.new(name)
    rescue NameError
    end

    # Public: Updates the attributes of the given model
    #
    # attributes - The Hash of attributes to be updated
    def update_attributes(attributes)
      attributes.each do |key, value|
        send(:"#{key}=", value)
      end
    end

    # Internal: Establish the _has_one_ relation.
    #
    # name -  The Symbol of the attribute to be related with the model
    # model - The Model to related with the given key
    def self.has_one(name, model)
      define_method(name) do
        @_memoized[name] ||= model.load.new
      end

      attributes << name unless attributes.include?(name)
    end

    # Internal: Defines a method with the name of attribute for the model.
    # name - The String name of the attribute
    def self.attribute(name)
      define_method(name) do
        @_attributes[name]
      end

      define_method(:"#{name}=") do |value|
        @_attributes[name] = value
      end

      attributes << name unless attributes.include?(name)
    end

    # Public: The Array of attributes names
    #
    # Returns Array of attributes
    def self.attributes
      @attributes ||= []
    end
  end
end
