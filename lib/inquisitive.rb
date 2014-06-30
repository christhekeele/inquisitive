module Inquisitive

  class << self

    def [](object)
      Inquisitive.const_get(:"#{object.class}", false).new object
    rescue NameError
      object
    end

    def present?(object)
      case object
      when ::String
        not object.empty?
      when ::Array
        object.any? do |value|
          Inquisitive.present? value
        end
      when ::Hash
        object.values.any? do |value|
          Inquisitive.present? value
        end
      else
        !!object
      end
    end

  end

private

  def predicate_method?(string)
    string[-1] == '?'
  end

  def predication(string)
    string[0..-2]
  end

end

require "inquisitive/string"
require "inquisitive/array"
unless Object.const_defined? :HashWithIndifferentAccess
  require "inquisitive/hash_with_indifferent_access"
end
require "inquisitive/hash"
require "inquisitive/environment"