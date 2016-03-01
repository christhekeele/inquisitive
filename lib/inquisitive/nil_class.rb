require 'inquisitive/utils'

module Inquisitive
  class NilClass
    include Inquisitive::Utils

    def initialize(object=nil); end

    attr_accessor :negated
    def not
      self.dup.tap{ |s| s.negated = !s.negated }
    end
    alias_method :exclude, :not
    alias_method :no, :not

    undef_method :nil?, :inspect, :to_s

    def present?
      presence
    end

  # Since we can't subclass NilClass
  #  (it has no allocate method)
  #  we fake its identity.
    def instance_of?(klass)
      klass == ::NilClass or super
    end
    alias_method :kind_of?, :instance_of?
    alias_method :is_a?, :instance_of?

    def == other
      other.nil?
    end
    def === other
      other.class == Class and other == ::NilClass or super
    end

    def to_str
      ""
    end

  private

    def respond_to_missing?(method_name, include_private = false)
      true # nil.respond_to? method_name or predicate_method? method_name
    end
    def method_missing(method_name, *arguments, &block)
      if nil.respond_to? method_name
        nil.send method_name, *arguments, &block
      elsif predicate_method? method_name
        presence
      else
        self
      end
    end

    def presence
      false ^ negated
    end

  end
end
