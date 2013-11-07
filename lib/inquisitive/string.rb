module Inquisitive
  class String < ::String
    include Inquisitive

    attr_accessor :negated
    def not
      self.dup.tap{ |s| s.negated = !s.negated }
    end

  private

    def respond_to_missing?(method_name, include_private = false)
      predicate_method? method_name
    end
    def method_missing(method_name, *arguments)
      if predicate_method? method_name
        (self == predication(method_name)) ^ negated
      else
        super
      end
    end

  end
end
