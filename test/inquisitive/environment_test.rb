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

  def test_autonaming_of_inquirers
    App.inquires_about 'NAME_NOT_SPECIFIED'
    assert App.respond_to? :name_not_specified
  end

  def test_default_mode_of_static
    ENV['DEFAULTS_TO'] = 'static'
    App.inquires_about 'DEFAULTS_TO'
    ENV['DEFAULTS_TO'] = 'lazy'
    assert App.defaults_to.static?
    ENV['DEFAULTS_TO'] = 'dynamic'
    assert App.defaults_to.static?
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

  %w[true True TrUe TRUE yes Yes YeS YES 1].each do |truthy_var|
    define_method :"test_truthy_var_#{truthy_var}" do
      ENV['TRUTHY'] = truthy_var
      App.inquires_about 'TRUTHY', present_if: App.truthy
      assert App.truthy?
    end
  end

end
