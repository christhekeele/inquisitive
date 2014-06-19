module Inquisitive
####
# A trimmed down version of ActiveSupport 4.0's HashWithIndifferentAccess
#  modified slightly so we don't have to inject behaviour into Hash.
# It lacks all `deep_` transforms since that requires patching Object and Array.
##
  class HashWithIndifferentAccess < ::Hash

    def extractable_options?
      true
    end
    def with_indifferent_access
      dup
    end
    def nested_under_indifferent_access
      self
    end

    def self.[](*args)
      new.merge!(::Hash[*args])
    end

    def initialize(constructor = {}, &block)
      if constructor.is_a?(::Hash)
        super()
        steal_default_from(constructor)
        update(constructor)
      else
        super(constructor)
      end.tap do |hash|
        self.default_proc = block if block_given?
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
      if other_hash.is_a? self.class
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
    
    # not sure why just this one Enumerable method fails tests without override
    def reject(*args, &block)
      self.class[super]
    end

    def values_at(*indices)
      indices.collect {|key| self[convert_key(key)]}
    end

    def dup
      self.class.new(self).tap do |new_hash|
        new_hash.default = default
      end
    end

    def merge(hash, &block)
      self.dup.update(hash, &block)
    end

    def replace(other_hash)
      super(self.class.new(other_hash))
    end

    def delete(key)
      super(convert_key(key))
    end

    def transform_keys
      result = {}
      each_key do |key|
        result[yield(key)] = self[key]
      end
      result
    end

    def transform_keys!
      keys.each do |key|
        self[yield(key)] = delete(key)
      end
      self
    end

    def symbolize_keys
      transform_keys{ |key| key.to_sym rescue key }
    end

    def symbolize_keys!
      transform_keys!{ |key| key.to_sym rescue key }
    end

    def assert_valid_keys(*valid_keys)
      valid_string_keys = valid_keys.flatten.map(&:to_s).uniq
      each_key do |k|
        raise ArgumentError.new("Unknown key: #{k}") unless valid_string_keys.include?(k)
      end
    end

    def stringify_keys!; self end
    def stringify_keys; dup end
    def to_options!; self end

    def select(*args, &block)
      dup.tap {|hash| hash.select!(*args, &block)}
    end

    def to_hash
      _new_hash= {}
      each do |key, value|
        _new_hash[convert_key(key)] = convert_value(value, for: :to_hash)
      end
      ::Hash.new(default).merge!(_new_hash)
    end

  protected

    def steal_default_from(hash)
      if hash.default_proc
        self.default_proc = hash.default_proc
      else
        self.default = hash.default
      end
    end

    def convert_key(key)
      key.kind_of?(Symbol) ? key.to_s : key
    end

    def convert_value(value, options = {})
      if value.is_a? ::Hash
        if options[:for] == :to_hash
          value.to_hash
        else
          if value.is_a? self.class
            value
          else
            self.class.new value
          end
        end
      elsif value.is_a?(::Array)
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
