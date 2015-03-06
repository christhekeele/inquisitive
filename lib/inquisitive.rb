module Inquisitive

  class << self

    def coerce(object)
      coerce! object
    rescue NameError
      object
    end
    alias_method :[], :coerce

    def coerce!(object)
      if Inquisitive.object? object
        object
      else
        Inquisitive.const_get(:"#{object.class}", false).new object
      end
    end

    def present?(object)
      case object
      when ::String, String
        not object.empty?
      when ::Array, Array
        object.any? do |value|
          Inquisitive.present? value
        end
      when ::Hash, Hash
        object.values.any? do |value|
          Inquisitive.present? value
        end
      when ::NilClass, NilClass
        false
      else
        if object.respond_to?(:present?)
          object.present?
        else
          !!object
        end
      end
    end

    def object?(object)
      object.class.name.start_with? 'Inquisitive::'
    end

  end

end

require "inquisitive/nil_class"
require "inquisitive/string"
require "inquisitive/array"
unless Object.const_defined? :HashWithIndifferentAccess
  require "inquisitive/hash_with_indifferent_access"
end
require "inquisitive/hash"
require "inquisitive/environment"
