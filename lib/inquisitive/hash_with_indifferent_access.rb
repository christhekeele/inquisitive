module Inquisitive
####
# A trimmed down version of ActiveSupport 4.0's HashWithIndifferentAccess
#  with instanciation and basic read/write only (no deep_merging, etc)
#  modified slightly so we don't have to inject behaviour into Hash.
##
  class HashWithIndifferentAccess < ::Hash

    def self.new_from_hash_copying_default(hash)
      new(hash).tap do |new_hash|
        new_hash.default = hash.default
      end
    end

    def self.[](*args)
      new.merge!(::Hash[*args])
    end

    def initialize(constructor = {})
      if constructor.is_a?(::Hash)
        super()
        update(constructor)
      else
        super(constructor)
      end
    end

    def default(key = nil)
      if key.is_a?(Symbol) && include?(key = key.to_s)
        self[key]
      else
        super
      end
    end

    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    def []=(key, value)
      regular_writer(convert_key(key), convert_value(value, for: :assignment))
    end

    alias_method :store, :[]=

    def update(other_hash)
      ####
      # modification
      # from:
      #   if other_hash.is_a? HashWithIndifferentAccess
      if other_hash.is_a? self.class
      # end modification
      ####
        super(other_hash)
      else
        other_hash.each_pair do |key, value|
          if block_given? && key?(key)
            value = yield(convert_key(key), self[key], value)
          end
          regular_writer(convert_key(key), convert_value(value))
        end
        self
      end
    end

    alias_method :merge!, :update

    def key?(key)
      super(convert_key(key))
    end

    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?

    def fetch(key, *extras)
      super(convert_key(key), *extras)
    end

    def values_at(*indices)
      indices.collect {|key| self[convert_key(key)]}
    end

    def dup
      self.class.new(self).tap do |new_hash|
        new_hash.default = default
      end
    end

    def select(*args, &block)
      dup.tap {|hash| hash.select!(*args, &block)}
    end

    def to_hash
      _new_hash= {}
      each do |key, value|
        _new_hash[convert_key(key)] = convert_value(value, for: :to_hash)
      end
      Hash.new(default).merge!(_new_hash)
    end

  protected

    def convert_key(key)
      key.kind_of?(Symbol) ? key.to_s : key
    end

    def convert_value(value, options = {})
      if value.is_a? ::Hash
        if options[:for] == :to_hash
          value.to_hash
        else
          ####
          # modification
          # from:
          #   value.nested_under_indifferent_access
          # so that we needn't add that method to Hash
          if value.is_a? self.class
            value
          else
            self.class.new_from_hash_copying_default value
          end
          # end modification
          ####
        end
      elsif value.is_a?(Array)
        unless options[:for] == :assignment
          value = value.dup
        end
        value.map! { |e| convert_value(e, options) }
      else
        value
      end
    end

  end

end
