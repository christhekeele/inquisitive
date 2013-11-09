module CombinatorialEnvironmentTests

  def test_type_is_parsed_correctly
    assert_kind_of(
      Object.const_get(:"#{@type.capitalize}"),
      App.send(@type)
    )
  end

  def test_type_is_converted_correctly
    assert_kind_of(
      Inquisitive.const_get(:"#{@type.capitalize}"),
      App.send(@type)
    )
  end

  def test_changing_variable_after_definition
    App.inquires_about @type.upcase, mode: @mode, with: :precache
    test = @mode.static? ? :assert_equal : :refute_equal
    precache = App.precache
    send :"change_#{@type}_variable"
    send test, App.send(@type), precache
  end

  def test_changing_variable_after_invocation
    test = @mode.dynamic? ? :assert_change : :refute_change
    monitor = -> { App.send(@type) }
    send test, monitor do
      send :"change_#{@type}_variable"
    end
  end

end
