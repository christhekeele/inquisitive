require 'test_helper'

class InquisitiveCombinatorialEnvironmentTest < EnvironmentTest

  def setup
    super
    ENV['STRING'] = @raw_string
    ENV['ARRAY'] = @raw_array.join(',')
    ENV['HASH__AUTHENTICATION'] = @raw_hash[:authentication].to_s
    ENV['HASH__IN'] = @raw_hash[:in]
    ENV['HASH__DATABASES'] = @raw_hash[:databases].join(',')
  end
  def teardown
    super
    ENV.delete 'STRING'
    ENV.delete 'ARRAY'
    ENV.delete 'HASH__AUTHENTICATION'
    ENV.delete 'HASH__IN'
    ENV.delete 'HASH__DATABASES'
    ENV.delete 'HASH__SOMETHING_NEW'
  end

  def change_string_variable
    ENV['STRING'] = 'something_new'
  end
  def change_array_variable
    ENV['ARRAY'] = [ ENV['ARRAY'], 'something_new' ].join ','
  end
  def change_hash_variable
    ENV['HASH__SOMETHING_NEW'] = 'true'
  end

end

%w[dynamic lazy static].each do |mode|
  %w[string array hash].each do |type|

    Inquisitive.const_set(
      :"Inquisitive#{mode.capitalize}#{type.capitalize}EnvironmentTest",
      Class.new(InquisitiveCombinatorialEnvironmentTest) do

        class << self
          attr_accessor :mode, :type
        end

        def setup
          super
          @mode = Inquisitive[self.class.mode]
          @type = Inquisitive[self.class.type]
          App.inquires_about @type.upcase, mode: @mode
        end

        def string
          App.string
        end
        def array
          App.array
        end
        def hash
          App.hash
        end

        include CombinatorialEnvironmentTests

      end
    ).tap do |klass|
      klass.mode = mode
      klass.type = type
    end.send :include, Object.const_get(:"#{type.capitalize}Tests")
    # Mixes in type-specific tests to ensure lookup behaves normally
    #  when accessed through the modes of App getters

  end
end
