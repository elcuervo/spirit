require 'net/http/pool'
require 'json'

module Spirit
  # Internal: Used for lazy evaluation of the model.
  #           This is the magic behind the asignation of relations when they
  #           are not defined yet.
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
    def initialize(name, &block)
      @name = name
      @block = block
    end

    # Internal: Raises an error for the missing method or the missing class.
    def method_missing(method, *args)
      message = "Call to %s#%s, but not defined." % [@name, method]
      ::Kernel.raise(::NoMethodError, message)
    end

    # Public: Used to force eager loading so we can have a common API
    def self.eager(object)
      object.class == self ? object : new(object.inspect) { object }
    end

    # Public: Loads the lazy-loaded model
    def load
      @block.call
    end
  end # end LazyModel

  # Public:
  class Collection < Array
    # Public: Initializes the collection for a given model
    def initialize(model)
      @model = model
    end

    # Public: Creates a new model for the collection and pushes it to current
    #         list.
    #
    # attributes - The Hash of attributes
    def create(attributes = {})
      self.push @model.create(attributes)
    end
  end # end Collection

  # Public: The model itself
  #         Use is throght extension
  #
  # Returns a Spirit::Model
  class Model
    DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }
    # Public: Initializes a Spirit::Model
    #
    # attributes - The Hash of the attributes of the model
    def initialize(attributes = {})
      @pool = Net::HTTP::Pool.new('http://localhost:4000')
      @_attributes = {}
      @_memoized = {}

      update_attributes(attributes)
    end

    def update_attributes(attributes)
      attributes.each do |key, value|
        send(:"#{key}=", value) if respond_to?(:"#{key}=")
      end
    end

    # Private: TODO
    class << self
      # Internal: Magically constructs a LazyModel for future evaluation.
      #
      # name - The Symbol of the class to be lazy loaded
      def const_missing(name)
        model = LazyModel.new(name) { const_get(name) }
        begin
          super(name)
        rescue NameError
        end
        model
      end

      # Private: TODO
      def lazy_load(name, model)
        define_method(name) do
          @_memoized[name] ||= begin
            return @_attributes[name] if @_attributes[name]
            lazy_model = LazyModel.eager(model)

            if lazy_model.load.kind_of?(Spirit::Collection)
              lazy_model.load
            else
              lazy_model.load.new
            end
          end
        end
      end

      # Private: TODO
      def lazy_set(name)
        define_method(:"#{name}=") do |value|
          if value.is_a?(Hash)
            self.send(name).update_attributes(value)
            value = self.send(name)
          end
          value.attributes.each do |attribute|
            if attribute.is_a?(Array)
              key, model = attribute
              if self.class == model
                value.update_attributes(Hash[key, self])
                value.parents << self.class
              end
            end
          end
          @_attributes[name] = value
        end
      end

      # Internal: Establish the relation.
      #
      # name -  The Symbol of the attribute to be related with the model
      # model - The Model to related with the given key
      def relation(name, model)
        lazy_load(name, model)
        lazy_set(name)

        attributes << Array[name, model] unless attributes.include?(name)
      end
      alias belongs_to relation
      alias has_one relation

      # Internal: Establish a collection as a relation
      #
      # name -  The Symbol of the attribute to be related with the model
      # model - The Model to related with the given collection
      def has_many(name, model)
        relation(name, Collection.new(model))
      end

      # Public: Creates a new model
      #
      # attributes - The Hash of attributes
      def create(attributes = {})
        model = new(attributes)
        model.create(@_resource)
        model
      end

      # Internal: Defines a method with the name of attribute for the model.
      # name - The String name of the attribute
      def attribute(name)
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
      def attributes
        @attributes ||= []
      end

      def parents
        @parents ||= []
      end

      def resource(resource)
        @_resource = resource
      end

      def site(url)
        @_site = url
      end
    end # end class

    def create(resource)
      @pool.post("/" + resource, to_hash.to_json, DEFAULT_HEADERS) do |res|
        new_attributes = JSON res.body
        update_attributes(new_attributes)
      end
    end

    def attributes
      @_attributes
    end

    def resource
      @_resource
    end

    def parents
      @parents ||= []
    end

    def to_hash
      hash = {}
      attributes.each do |key, value|
        new_value = case
                    when parents.include?(value.class)
                    when value.is_a?(Spirit::Model)
                      value.to_hash
                    else
                      value
                    end
        hash[key] = new_value if new_value
      end
      hash
    end

  end # end Model
end #end Spirit
