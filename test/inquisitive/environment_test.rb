require 'test_helper'

class InquisitiveEnvironmentTest < EnvironmentTest

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

end
