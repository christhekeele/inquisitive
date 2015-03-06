require 'inquisitive/utils'

module Inquisitive
  class Hash < HashWithIndifferentAccess
    include Inquisitive::Utils

    attr_accessor :negated
    def no
      dup.tap{ |s| s.negated = !s.negated }
    end

    def === other
      other.class == Class and other == ::Hash or super
    end

    alias_method :regular_reader, :[] unless method_defined?(:regular_reader)
    def [](key)
      Inquisitive[regular_reader key]
    end

    def fetch(key, default=nil)
      key = convert_key(key)
      value = self[key]
      if Inquisitive.present? value
        value
      else
        if block_given?
          yield(key)
        elsif default
          default
        else
          raise KeyError, "key not found: #{key}"
        end
      end
    end

  protected

    def convert_value(value, options={})
      if options[:for] == :assignment
        return if value.kind_of? NilClass
      end
      super(Inquisitive[value], options)
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
