module Inquisitive
  class Hash < HashWithIndifferentAccess
    include Inquisitive

    attr_accessor :negated
    def no
      dup.tap{ |s| s.negated = !s.negated }
    end

    def convert_value(value, options={})
      super(Inquisitive[value], options)
    end

    def === other
      other.class == Class and other == ::Hash or super
    end

  private

    def dup
      super.tap{ |duplicate| duplicate.negated = self.negated }
    end

    def respond_to_missing?(method_name, include_private = false)
      predicate_method?(method_name) or has_key?(method_name)
    end
    def method_missing(method_name, *arguments)
      if predicate_method? method_name
        if has_key? predication(method_name)
          Inquisitive.present? self[predication(method_name)]
        else
          false
        end ^ negated
      else
        Inquisitive[self[method_name]]
      end
    end

  end

end
