require 'test_helper'

class InquisitiveEnvironmentTest < EnvironmentTest

  def test_missing_variable_responses
    App.inquires_about 'DOES_NOT_EXIST', with: :exists
    assert_equal "", App.exists
  end
  def test_missing_variable_predicates
    App.inquires_about 'DOES_NOT_EXIST', with: :exists
    refute App.exists?
  end

  def test_missing_hash_variable_responses
    App.inquires_about 'DOES_NOT_EXIST_', with: :exists
    assert_equal App.exists, {}
  end
  def test_missing_hash_variable_predicates
    App.inquires_about 'DOES_NOT_EXIST_', with: :exists
    refute App.exists?
  end

  def test_autonaming_of_inquirers
    App.inquires_about 'NAME_NOT_SPECIFIED'
    assert App.respond_to? :name_not_specified
  end

  def test_default_mode_of_dynamic
    App.inquires_about 'DEFAULTS_TO', with: :defaults_to
    App.defaults_to # Call once to ensure no caching
    ENV['DEFAULTS_TO'] = 'dynamic'
    assert App.defaults_to.dynamic?
  end

  def test_custom_string_presence
    ENV['AUTHORIZABLE'] = 'false'
    App.inquires_about 'AUTHORIZABLE', present_if: 'true'
    refute App.authorizable?
  end

  def test_custom_regex_presence
    ENV['AUTHORIZABLE'] = 'not at all'
    App.inquires_about 'AUTHORIZABLE', present_if: /yes/
    refute App.authorizable?
  end

  def test_custom_class_presence
    ENV['AUTHORIZABLE'] = 'not at all'
    App.inquires_about 'AUTHORIZABLE', present_if: Array
    refute App.authorizable?
  end

end
