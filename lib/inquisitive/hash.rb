module Inquisitive
  class Hash < Inquisitive::HashWithIndifferentAccess
    include Inquisitive

    attr_accessor :negated
    def not
      self.dup.tap{ |s| s.negated = !s.negated }
    end

    class << self
      alias_method :make_inquisitive, :new
    end

    def initialize(constructor=nil)
      if constructor.is_a?(::Hash)
        super()
        update(constructor)
      else
        super(constructor)
      end
    end

    def convert_value(value, options={})
      super(Inquisitive[value], options)
    end

  private

    def respond_to_missing?(method_name, include_private = false)
      predicate_method?(method_name) or has_key?(method_name)
    end
    def method_missing(method_name, *arguments)
      if predicate_method? method_name
        if has_key? predication(method_name)
          (Inquisitive.present? self[predication(method_name)]) ^ negated
        else
          false
        end
      elsif has_key? method_name
        self[method_name]
      else
        super
      end
    end

  end

end
