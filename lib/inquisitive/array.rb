module Inquisitive
  class Array < ::Array
    include Inquisitive::Utils

    attr_accessor :negated
    def exclude
      self.dup.tap{ |a| a.negated = !a.negated }
    end

    def === other
      other.class == Class and other == ::Array or super
    end

  private

    def respond_to_missing?(method_name, include_private = false)
      predicate_method?(method_name)
    end
    def method_missing(method_name, *arguments)
      if predicate_method? method_name
        (include? predication(method_name)) ^ negated
      else
        super
      end
    end

  end
end
