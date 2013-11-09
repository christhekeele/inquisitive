require 'test_helper'

class InquisitiveHashWithIndifferentAccessTest < Test
  HashWithIndifferentAccess = Inquisitive::HashWithIndifferentAccess

  class IndifferentHash < HashWithIndifferentAccess
  end

  class SubclassingArray < Array
  end

  class SubclassingHash < Hash
  end

  def setup
    @strings                 = { 'a' => 1, 'b' => 2 }
    @nested_strings          = { 'a' => { 'b' => { 'c' => 3 } } }
    @symbols                 = { :a  => 1, :b  => 2 }
    @nested_symbols          = { :a  => { :b => { :c => 3 } } }
    @mixed                   = { :a  => 1, 'b' => 2 }
    @nested_mixed            = { 'a' => { :b => { 'c' => 3 } } }
    @fixnums                 = {  0  => 1,  1  => 2 }
    @nested_fixnums          = {  0  => { 1  => { 2 => 3} } }
    @illegal_symbols         = { []  => 3 }
    @nested_illegal_symbols  = { []  => { [] => 3} }
    @upcase_strings          = { 'A' => 1, 'B' => 2 }
    @nested_upcase_strings   = { 'A' => { 'B' => { 'C' => 3 } } }

    @indifferent_strings                 = HashWithIndifferentAccess.new @strings
    @indifferent_nested_strings          = HashWithIndifferentAccess.new @nested_strings
    @indifferent_symbols                 = HashWithIndifferentAccess.new @symbols
    @indifferent_nested_symbols          = HashWithIndifferentAccess.new @nested_symbols
    @indifferent_mixed                   = HashWithIndifferentAccess.new @mixed
    @indifferent_nested_mixed            = HashWithIndifferentAccess.new @nested_mixed
    @indifferent_fixnums                 = HashWithIndifferentAccess.new @fixnums
    @indifferent_nested_fixnums          = HashWithIndifferentAccess.new @nested_fixnums
    @indifferent_illegal_symbols         = HashWithIndifferentAccess.new @illegal_symbols
    @indifferent_nested_illegal_symbols  = HashWithIndifferentAccess.new @nested_illegal_symbols
    @indifferent_upcase_strings          = HashWithIndifferentAccess.new @upcase_strings
    @indifferent_nested_upcase_strings   = HashWithIndifferentAccess.new @nested_upcase_strings
  end

  def test_extractable_options?
    assert @indifferent_strings.extractable_options?
  end

  def test_with_indifferent_access
    assert_equal @indifferent_strings, @indifferent_strings.with_indifferent_access
  end

  def test_nested_under_indifferent_access
    assert_same @indifferent_strings, @indifferent_strings.nested_under_indifferent_access
  end

  def test_indifferent_transform_keys
    assert_equal @indifferent_upcase_strings, @indifferent_strings.transform_keys{ |key| key.to_s.upcase }
    assert_equal @indifferent_upcase_strings, @indifferent_symbols.transform_keys{ |key| key.to_s.upcase }
    assert_equal @indifferent_upcase_strings, @indifferent_mixed.transform_keys{ |key| key.to_s.upcase }
  end

  def test_indifferent_transform_keys_not_mutates
    transformed_hash = @indifferent_mixed.dup
    transformed_hash.transform_keys{ |key| key.to_s.upcase }
    assert_equal @indifferent_mixed, transformed_hash
  end

  def test_indifferent_transform_keys!
    assert_equal @indifferent_upcase_strings, @indifferent_symbols.dup.transform_keys!{ |key| key.to_s.upcase }
    assert_equal @indifferent_upcase_strings, @indifferent_strings.dup.transform_keys!{ |key| key.to_s.upcase }
    assert_equal @indifferent_upcase_strings, @indifferent_mixed.dup.transform_keys!{ |key| key.to_s.upcase }
  end

  def test_indifferent_transform_keys_with_bang_mutates
    transformed_hash = @indifferent_mixed.dup
    transformed_hash.transform_keys!{ |key| key.to_s.upcase }
    assert_equal @indifferent_upcase_strings, transformed_hash
    assert_equal @mixed, { :a => 1, "b" => 2 }
  end

  def test_indifferent_symbolize_keys
    assert_equal @symbols, @indifferent_symbols.symbolize_keys
    assert_equal @symbols, @indifferent_strings.symbolize_keys
    assert_equal @symbols, @indifferent_mixed.symbolize_keys
  end

  def test_indifferent_symbolize_keys_not_mutates
    transformed_hash = @indifferent_mixed.dup
    transformed_hash.symbolize_keys
    assert_equal @indifferent_mixed, transformed_hash
  end

  def test_indifferent_symbolize_keys!
    assert_equal @indifferent_symbols, @indifferent_symbols.dup.symbolize_keys!
    assert_equal @indifferent_symbols, @indifferent_strings.dup.symbolize_keys!
    assert_equal @indifferent_symbols, @indifferent_mixed.dup.symbolize_keys!
  end

  def test_indifferent_symbolize_keys_preserves_keys_that_cant_be_symbolized
    assert_equal @indifferent_illegal_symbols, @indifferent_illegal_symbols.symbolize_keys
    assert_equal @indifferent_illegal_symbols, @indifferent_illegal_symbols.dup.symbolize_keys!
  end

  def test_indifferent_stringify_keys
    assert_equal @indifferent_strings, @indifferent_symbols.stringify_keys
    assert_equal @indifferent_strings, @indifferent_strings.stringify_keys
    assert_equal @indifferent_strings, @indifferent_mixed.stringify_keys
  end

  def test_indifferent_stringify_keys_not_mutates
    transformed_hash = @indifferent_mixed.dup
    transformed_hash.stringify_keys
    assert_equal @indifferent_mixed, transformed_hash
  end

  def test_indifferent_stringify_keys!
    assert_equal @indifferent_strings, @indifferent_symbols.dup.stringify_keys!
    assert_equal @indifferent_strings, @indifferent_strings.dup.stringify_keys!
    assert_equal @indifferent_strings, @indifferent_mixed.dup.stringify_keys!
  end

  def test_indifferent_stringify_keys_with_bang_mutates
    transformed_hash = @indifferent_mixed.dup
    transformed_hash.stringify_keys!
    assert_equal @indifferent_strings, transformed_hash
    assert_equal @mixed, { :a => 1, "b" => 2 }
  end

  def test_indifferent_assorted
    @strings = HashWithIndifferentAccess.new @strings
    @symbols = HashWithIndifferentAccess.new @symbols
    @mixed   = HashWithIndifferentAccess.new @mixed

    assert_equal 'a', @strings.__send__(:convert_key, :a)

    assert_equal 1, @strings.fetch('a')
    assert_equal 1, @strings.fetch(:a.to_s)
    assert_equal 1, @strings.fetch(:a)

    hashes = { :@strings => @strings, :@symbols => @symbols, :@mixed => @mixed }
    method_map = { :'[]' => 1, :fetch => 1, :values_at => [1],
      :has_key? => true, :include? => true, :key? => true,
      :member? => true }

    hashes.each do |name, hash|
      method_map.sort_by { |m| m.to_s }.each do |meth, expected|
        assert_equal(expected, hash.__send__(meth, 'a'),
                     "Calling #{name}.#{meth} 'a'")
        assert_equal(expected, hash.__send__(meth, :a),
                     "Calling #{name}.#{meth} :a")
      end
    end

    assert_equal [1, 2], @strings.values_at('a', 'b')
    assert_equal [1, 2], @strings.values_at(:a, :b)
    assert_equal [1, 2], @symbols.values_at('a', 'b')
    assert_equal [1, 2], @symbols.values_at(:a, :b)
    assert_equal [1, 2], @mixed.values_at('a', 'b')
    assert_equal [1, 2], @mixed.values_at(:a, :b)
  end

  def test_indifferent_reading
    hash = HashWithIndifferentAccess.new
    hash["a"] = 1
    hash["b"] = true
    hash["c"] = false
    hash["d"] = nil

    assert_equal 1, hash[:a]
    assert_equal true, hash[:b]
    assert_equal false, hash[:c]
    assert_equal nil, hash[:d]
    assert_equal nil, hash[:e]
  end


  def test_indifferent_reading_with_nonnil_default
    hash = HashWithIndifferentAccess.new(1)
    hash["a"] = 1
    hash["b"] = true
    hash["c"] = false
    hash["d"] = nil

    assert_equal 1, hash[:a]
    assert_equal true, hash[:b]
    assert_equal false, hash[:c]
    assert_equal nil, hash[:d]
    assert_equal 1, hash[:e]
  end

  def test_indifferent_writing
    hash = HashWithIndifferentAccess.new
    hash[:a] = 1
    hash['b'] = 2
    hash[3] = 3

    assert_equal hash['a'], 1
    assert_equal hash['b'], 2
    assert_equal hash[:a], 1
    assert_equal hash[:b], 2
    assert_equal hash[3], 3
  end

  def test_indifferent_update
    hash = HashWithIndifferentAccess.new
    hash[:a] = 'a'
    hash['b'] = 'b'

    updated_with_strings = hash.update(@strings)
    updated_with_symbols = hash.update(@symbols)
    updated_with_mixed = hash.update(@mixed)

    assert_equal updated_with_strings[:a], 1
    assert_equal updated_with_strings['a'], 1
    assert_equal updated_with_strings['b'], 2

    assert_equal updated_with_symbols[:a], 1
    assert_equal updated_with_symbols['b'], 2
    assert_equal updated_with_symbols[:b], 2

    assert_equal updated_with_mixed[:a], 1
    assert_equal updated_with_mixed['b'], 2

    assert [updated_with_strings, updated_with_symbols, updated_with_mixed].all? { |h| h.keys.size == 2 }
  end

  def test_indifferent_merging
    hash = HashWithIndifferentAccess.new
    hash[:a] = 'failure'
    hash['b'] = 'failure'

    other = { 'a' => 1, :b => 2 }

    merged = hash.merge(other)

    assert_equal HashWithIndifferentAccess, merged.class
    assert_equal 1, merged[:a]
    assert_equal 2, merged['b']

    hash.update(other)

    assert_equal 1, hash[:a]
    assert_equal 2, hash['b']
  end

  def test_indifferent_replace
    hash = HashWithIndifferentAccess.new
    hash[:a] = 42

    replaced = hash.replace(b: 12)

    assert hash.key?('b')
    assert !hash.key?(:a)
    assert_equal 12, hash[:b]
    assert_same hash, replaced
  end

  def test_indifferent_merging_with_block
    hash = HashWithIndifferentAccess.new
    hash[:a] = 1
    hash['b'] = 3

    other = { 'a' => 4, :b => 2, 'c' => 10 }

    merged = hash.merge(other) { |key, old, new| old > new ? old : new }

    assert_equal HashWithIndifferentAccess, merged.class
    assert_equal 4, merged[:a]
    assert_equal 3, merged['b']
    assert_equal 10, merged[:c]

    other_indifferent = HashWithIndifferentAccess.new('a' => 9, :b => 2)

    merged = hash.merge(other_indifferent) { |key, old, new| old + new }

    assert_equal HashWithIndifferentAccess, merged.class
    assert_equal 10, merged[:a]
    assert_equal 5, merged[:b]
  end

  def test_indifferent_deleting
    get_hash = proc{ HashWithIndifferentAccess.new(:a => 'foo') }
    hash = get_hash.call
    assert_equal hash.delete(:a), 'foo'
    assert_equal hash.delete(:a), nil
    hash = get_hash.call
    assert_equal hash.delete('a'), 'foo'
    assert_equal hash.delete('a'), nil
  end

  def test_indifferent_select
    hash = HashWithIndifferentAccess.new(@strings).select {|k,v| v == 1}

    assert_equal({ 'a' => 1 }, hash)
    assert_instance_of HashWithIndifferentAccess, hash
  end

  def test_indifferent_select_returns_a_hash_when_unchanged
    hash = HashWithIndifferentAccess.new(@strings).select {|k,v| true}

    assert_instance_of HashWithIndifferentAccess, hash
  end

  def test_indifferent_select_bang
    indifferent_strings = HashWithIndifferentAccess.new(@strings)
    indifferent_strings.select! {|k,v| v == 1}

    assert_equal({ 'a' => 1 }, indifferent_strings)
    assert_instance_of HashWithIndifferentAccess, indifferent_strings
  end

  def test_indifferent_reject
    hash = HashWithIndifferentAccess.new(@strings).reject {|k,v| v != 1}

    assert_equal({ 'a' => 1 }, hash)
    assert_instance_of HashWithIndifferentAccess, hash
  end

  def test_indifferent_reject_bang
    indifferent_strings = HashWithIndifferentAccess.new(@strings)
    indifferent_strings.reject! {|k,v| v != 1}

    assert_equal({ 'a' => 1 }, indifferent_strings)
    assert_instance_of HashWithIndifferentAccess, indifferent_strings
  end

  def test_indifferent_to_hash
    # Should convert to a Hash with String keys.
    assert_equal @strings, HashWithIndifferentAccess.new(@mixed).to_hash

    # Should preserve the default value.
    mixed_with_default = @mixed.dup
    mixed_with_default.default = '1234'
    roundtrip = HashWithIndifferentAccess.new(mixed_with_default).to_hash
    assert_equal @strings, roundtrip
    assert_equal '1234', roundtrip.default

    # Should preserve the default proc.
    mixed_with_default_proc = @mixed.dup
    mixed_with_default_proc.default_proc = -> (h, k) { '1234' }
    roundtrip = HashWithIndifferentAccess.new(mixed_with_default_proc).to_hash
    assert_equal @strings, roundtrip
    assert_equal '1234', roundtrip.default

    # Should preserve access
    new_to_hash = HashWithIndifferentAccess.new(@nested_mixed).to_hash
    refute_instance_of HashWithIndifferentAccess, new_to_hash
    refute_instance_of HashWithIndifferentAccess, new_to_hash["a"]
    refute_instance_of HashWithIndifferentAccess, new_to_hash["a"]["b"]
  end

  def test_lookup_returns_the_same_object_that_is_stored_in_hash_indifferent_access
    hash = HashWithIndifferentAccess.new {|h, k| h[k] = []}
    hash[:a] << 1

    assert_equal [1], hash[:a]
  end

  def test_with_indifferent_access_has_no_side_effects_on_existing_hash
    hash = {content: [{:foo => :bar, 'bar' => 'baz'}]}
    HashWithIndifferentAccess.new(hash)

    assert_equal [:foo, "bar"], hash[:content].first.keys
  end

  def test_indifferent_hash_with_array_of_hashes
    hash = HashWithIndifferentAccess.new( "urls" => { "url" => [ { "address" => "1" }, { "address" => "2" } ] })
    assert_equal "1", hash[:urls][:url].first[:address]

    hash = hash.to_hash
    refute_instance_of HashWithIndifferentAccess, hash
    refute_instance_of HashWithIndifferentAccess, hash["urls"]
    refute_instance_of HashWithIndifferentAccess, hash["urls"]["url"].first
  end

  def test_should_preserve_array_subclass_when_value_is_array
    array = SubclassingArray.new
    array << { "address" => "1" }
    hash = HashWithIndifferentAccess.new "urls" => { "url" => array }
    assert_equal SubclassingArray, hash[:urls][:url].class
  end

  def test_should_preserve_array_class_when_hash_value_is_frozen_array
    array = SubclassingArray.new
    array << { "address" => "1" }
    hash = HashWithIndifferentAccess.new "urls" => { "url" => array.freeze }
    assert_equal SubclassingArray, hash[:urls][:url].class
  end

  def test_stringify_and_symbolize_keys_on_indifferent_preserves_hash
    h = HashWithIndifferentAccess.new
    h[:first] = 1
    h = h.stringify_keys
    assert_equal 1, h['first']
    h = HashWithIndifferentAccess.new
    h['first'] = 1
    h = h.symbolize_keys
    assert_equal 1, h[:first]
  end

  def test_to_options_on_indifferent_preserves_hash
    h = HashWithIndifferentAccess.new
    h['first'] = 1
    h.to_options!
    assert_equal 1, h['first']
  end

  def test_indifferent_subhashes
    h = HashWithIndifferentAccess.new 'user' => {'id' => 5}
    ['user', :user].each {|user| [:id, 'id'].each {|id| assert_equal 5, h[user][id], "h[#{user.inspect}][#{id.inspect}] should be 5"}}

    h = HashWithIndifferentAccess.new :user => {:id => 5}
    ['user', :user].each {|user| [:id, 'id'].each {|id| assert_equal 5, h[user][id], "h[#{user.inspect}][#{id.inspect}] should be 5"}}
  end

  def test_indifferent_duplication
    # Should preserve default value
    h = HashWithIndifferentAccess.new
    h.default = '1234'
    assert_equal h.default, h.dup.default

    # Should preserve class for subclasses
    h = IndifferentHash.new
    assert_equal h.class, h.dup.class
  end

  def test_assert_valid_keys
    refute_raise do
      HashWithIndifferentAccess.new(:failure => "stuff", :funny => "business").
        assert_valid_keys([ :failure, :funny ])
      HashWithIndifferentAccess.new(:failure => "stuff", :funny => "business").
        assert_valid_keys(:failure, :funny)
    end

    assert_raises(ArgumentError, "Unknown key: failore") do
      HashWithIndifferentAccess.new(:failore => "stuff", :funny => "business").
        assert_valid_keys([ :failure, :funny ])
      HashWithIndifferentAccess.new(:failore => "stuff", :funny => "business").
        assert_valid_keys(:failure, :funny)
    end
  end

  def test_store_on_indifferent_access
    hash = HashWithIndifferentAccess.new
    hash.store(:test1, 1)
    hash.store('test1', 11)
    hash[:test2] = 2
    hash['test2'] = 22
    expected = { "test1" => 11, "test2" => 22 }
    assert_equal expected, hash
  end

  def test_constructor_on_indifferent_access
    hash = HashWithIndifferentAccess[:foo, 1]
    assert_equal 1, hash[:foo]
    assert_equal 1, hash['foo']
    hash[:foo] = 3
    assert_equal 3, hash[:foo]
    assert_equal 3, hash['foo']
  end

  def test_should_use_default_value_for_unknown_key
    hash_wia = HashWithIndifferentAccess.new(3)
    assert_equal 3, hash_wia[:new_key]
  end

  def test_should_use_default_value_if_no_key_is_supplied
    hash_wia = HashWithIndifferentAccess.new(3)
    assert_equal 3, hash_wia.default
  end

  def test_should_nil_if_no_default_value_is_supplied
    hash_wia = HashWithIndifferentAccess.new
    assert_nil hash_wia.default
  end

  def test_should_copy_the_default_value_when_converting_to_hash_with_indifferent_access
    hash = Hash.new(3)
    hash_wia = HashWithIndifferentAccess.new(hash)
    assert_equal 3, hash_wia.default
  end

end
