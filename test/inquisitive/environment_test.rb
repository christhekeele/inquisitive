require 'test_helper'

class InquisitiveEnvironmentTest < EnvironmentTest

  def test_missing_variable_predicates
    App.inquires_about 'DOES_NOT_EXIST', with: :exists
    refute App.exists?
  end

  def test_autonaming_of_inquirers
    App.inquires_about 'NAME_NOT_SPECIFIED'
    assert App.respond_to? :name_not_specified
  end

  def test_custom_string_presence
    App.inquires_about 'AUTHORIZABLE', present_if: 'true'
    ENV['AUTHORIZABLE'] = 'false'
    refute App.authorizable?
    ENV['AUTHORIZABLE'] = 'true'
    assert App.authorizable?
  end

  def test_custom_regex_presence
    App.inquires_about 'AUTHORIZABLE', present_if: /yes/
    ENV['AUTHORIZABLE'] = 'false'
    refute App.authorizable?
    ENV['AUTHORIZABLE'] = 'yes'
    assert App.authorizable?
  end

  def test_custom_class_presence
    App.inquires_about 'AUTHORIZABLE', present_if: Array
    ENV['AUTHORIZABLE'] = 'false'
    refute App.authorizable?
    ENV['AUTHORIZABLE'] = 'false,schmalse'
    assert App.authorizable?
  end

  %w[true True TrUe TRUE yes Yes YeS YES 1].each do |truthy_var|
    define_method :"test_truthy_var_#{truthy_var}" do
      App.inquires_about 'TRUTHY', present_if: App.truthy
      ENV['TRUTHY'] = 'false'
      refute App.truthy?
      ENV['TRUTHY'] = truthy_var
      assert App.truthy?
    end
  end

  %w[false False FaLsE FALSE no No nO NO 0 anything_else].each do |falsey_var|
    define_method :"test_falsey_var_#{falsey_var}" do
      App.inquires_about 'TRUTHY', present_if: App.truthy
      ENV['TRUTHY'] = 'true'
      assert App.truthy?
      ENV['TRUTHY'] = falsey_var
      refute App.truthy?
    end
  end

  def test_array_squishing
    App.inquires_about 'SQUISHIBLE_ARRAY'
    ENV['SQUISHIBLE_ARRAY'] = 'foo, bar,  baz'
    assert_equal %w[foo bar baz], App.squishible_array
  end

  def test_default_accessor_for_missing
    App.inquires_about 'MISSING_WITH_DEFAULT', default: 'default'
    assert_equal 'default', App.missing_with_default
  end

  def test_default_predicate_for_missing
    App.inquires_about 'MISSING_WITH_DEFAULT', default: 'default'
    assert App.missing_with_default?
  end

  def test_default_accessor_for_existing
    App.inquires_about 'EXISTING_WITH_DEFAULT', default: 'default'
    ENV['EXISTING_WITH_DEFAULT'] = @raw_string
    assert_equal @raw_string, App.existing_with_default
  end

  def test_default_predicate_for_existing
    App.inquires_about 'EXISTING_WITH_DEFAULT', default: 'default'
    ENV['EXISTING_WITH_DEFAULT'] = @raw_string
    assert App.existing_with_default?
  end

end
