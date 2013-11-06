module Inquisitive
  class HashWithIndifferentAccess < ::Hash
    include Inquisitive

####
# Copied from https://github.com/rails/rails/blob/ee95bbfb4748485866f9635fece075e33a95f4d0/activesupport/lib/active_support/core_ext/hash/keys.rb
##
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

  def stringify_keys
    transform_keys{ |key| key.to_s }
  end

  def stringify_keys!
    transform_keys!{ |key| key.to_s }
  end

  def symbolize_keys
    transform_keys{ |key| key.to_sym rescue key }
  end
  alias_method :to_options,  :symbolize_keys

  def symbolize_keys!
    transform_keys!{ |key| key.to_sym rescue key }
  end
  alias_method :to_options!, :symbolize_keys!

  def assert_valid_keys(*valid_keys)
    valid_keys.flatten!
    each_key do |k|
      raise ArgumentError.new("Unknown key: #{k}") unless valid_keys.include?(k)
    end
  end

  def deep_transform_keys(&block)
    result = {}
    each do |key, value|
      result[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys(&block) : value
    end
    result
  end

  def deep_transform_keys!(&block)
    keys.each do |key|
      value = delete(key)
      self[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys!(&block) : value
    end
    self
  end

  def deep_stringify_keys
    deep_transform_keys{ |key| key.to_s }
  end

  def deep_stringify_keys!
    deep_transform_keys!{ |key| key.to_s }
  end

  def deep_symbolize_keys
    deep_transform_keys{ |key| key.to_sym rescue key }
  end

  def deep_symbolize_keys!
    deep_transform_keys!{ |key| key.to_sym rescue key }
  end

####
# Copied from https://github.com/rails/rails/blob/ee95bbfb4748485866f9635fece075e33a95f4d0/activesupport/lib/active_support/hash_with_indifferent_access.rb
##

  def nested_under_indifferent_access
    self
  end

  def initialize(constructor = {})
    if constructor.is_a?(Hash)
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

  def self.new_from_hash_copying_default(hash)
    new(hash).tap do |new_hash|
      new_hash.default = hash.default
    end
  end

  def self.[](*args)
    new.merge!(Hash[*args])
  end

  alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
  alias_method :regular_update, :update unless method_defined?(:regular_update)

  def []=(key, value)
    regular_writer(convert_key(key), convert_value(value, for: :assignment))
  end

  alias_method :store, :[]=

  def update(other_hash)
    if other_hash.is_a? HashWithIndifferentAccess
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

  def merge(hash, &block)
    self.dup.update(hash, &block)
  end

  def reverse_merge(other_hash)
    super(self.class.new_from_hash_copying_default(other_hash))
  end

  def reverse_merge!(other_hash)
    replace(reverse_merge( other_hash ))
  end

  def replace(other_hash)
    super(self.class.new_from_hash_copying_default(other_hash))
  end

  def delete(key)
    super(convert_key(key))
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
      if value.is_a? Hash
        if options[:for] == :to_hash
          value.to_hash
        else
          value.nested_under_indifferent_access
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
