module Inquisitive
  class Array < ::Array

    class << self
      alias_method :make_inquisitive, :new
    end

    def include
      Inquisition.new self
    end
    def exclude
      self.include.tap{ |a| a.negated = !a.negated }
    end

  private

    class Inquisition
      include Inquisitive
      attr_accessor :negated, :array
      def initialize(array=[])
        @array = array
      end
      def respond_to_missing?(method_name, include_private = false)
        predicate_method?(method_name)
      end
      def method_missing(method_name, *arguments)
        if predicate_method? method_name
          (array.include? predication(method_name)) ^ negated
        else
          super
        end
      end
    end

  end
end
