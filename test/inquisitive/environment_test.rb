require 'test_helper'

module Inquisitive
  class EnvironmentTest < Test

    def setup
      super
      ENV['STRING'] = @raw_string
      ENV['ARRAY'] = @raw_array.join(',')
      ENV['HASH_AUTHENTICATION'] = @raw_hash[:authentication].to_s
      ENV['HASH_IN'] = @raw_hash[:in]
      ENV['HASH_SERVICES'] = @raw_hash[:services]
      Object.const_set :App, Module.new
      App.extend Inquisitive::Environment
    end
    def teardown
      super
      ENV['STRING'] = ''
      ENV['ARRAY'] = ''
      ENV['HASH_AUTHENTICATION'] = ''
      ENV['HASH_IN'] = ''
      ENV['HASH_SERVICES'] = ''
      Object.send :remove_const, :App
    end

  end

  %w[dynamic cached static].each do |mode|
    %w[string array hash].each do |variable|

      Inquisitive.const_set(:"#{mode.capitalize}#{variable.capitalize}EnvironmentTest",
        Class.new(EnvironmentTest) do

          class << self
            attr_accessor :mode, :variable
          end

          def setup
            super
            @mode = self.class.mode
            @variable = self.class.variable
            App.inquires_about @variable.upcase, mode: @mode
            self.instance_variable_set :"@#{@variable}", App.send(@variable)
          end

          def test_variable_is_parsed_correctly
            assert_kind_of(
              Object.const_get(:"#{@variable.capitalize}"),
              App.send(@variable)
            )
          end

          def test_variable_is_converted_correctly
            assert_kind_of(
              Inquisitive.const_get(:"#{@variable.capitalize}"),
              App.send(@variable)
            )
          end

        end
      ).tap do |klass|
      klass.mode = mode
      klass.variable = variable
    end.send :include, Object.const_get(:"#{variable.capitalize}Tests")

    end
  end

end
