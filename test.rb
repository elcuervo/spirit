module T
  class M
    def self.attributes(*symbols)
      puts symbols
    end

    def find
    end
  end
end

class A < T::M
  attributes :name, :address
end

a = A.new
puts a.methods - Object.methods
