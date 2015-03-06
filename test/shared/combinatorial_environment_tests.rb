module CombinatorialEnvironmentTests

  def test_type_is_parsed_correctly
    assert_kind_of(
      Object.const_get(:"#{type_const_name}"),
      App.send(@type)
    )
  end

  def test_type_is_converted_correctly
    assert_kind_of(
      Inquisitive.const_get(:"#{type_const_name}"),
      App.send(@type)
    )
  end

  def test_changing_variable
    App.inquires_about @type.upcase, with: :changeable
    assert_change ->{ App.changeable } do
      send :"change_#{@type}_variable"
    end
  end

private

  def type_const_name
    @type == 'nil_object' ? 'NilClass' : @type.capitalize
  end

end
