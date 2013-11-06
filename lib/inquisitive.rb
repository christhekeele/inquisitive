require 'pry'

module Inquisitive

  class << self

    def [](object)
      if Inquisitive.constants.include?(:"#{object.class}") and Inquisitive.const_get(:"#{object.class}").is_a?(Class)
        Inquisitive.const_get(:"#{object.class}").make_inquisitive object
      else
        object
      end
    end

    def present?(object)
      case object
      when String
        not object.empty?
      when Array
        object.any? do |value|
          Inquisitive.present? value
        end
      when Hash
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

unless Object.const_defined? :HashWithIndifferentAccess
  require_relative "inquisitive/hash_with_indifferent_access"
end
require_relative "inquisitive/string"
require_relative "inquisitive/array"
require_relative "inquisitive/hash"
require_relative "inquisitive/environment"

binding.pry
