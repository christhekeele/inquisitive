class InquisitiveCombinatorialEnvironmentTest < EnvironmentTest

  def setup
    super
    ENV['STRING'] = @raw_string
    ENV['ARRAY'] = @raw_array.join(',')
    ENV['HASH_AUTHENTICATION'] = @raw_hash[:authentication].to_s
    ENV['HASH_IN'] = @raw_hash[:in]
    ENV['HASH_DATABASES'] = @raw_hash[:databases].join(',')
  end
  def teardown
    super
    ENV.delete 'STRING'
    ENV.delete 'ARRAY'
    ENV.delete 'HASH_AUTHENTICATION'
    ENV.delete 'HASH_IN'
    ENV.delete 'HASH_DATABASES'
    ENV.delete 'HASH_SOMETHING_NEW'
  end

  def change_string_variable
    ENV['STRING'] = 'something_new'
  end
  def change_array_variable
    ENV['ARRAY'] = [ ENV['ARRAY'], 'something_new' ].join ','
  end
  def change_hash_variable
    ENV['HASH_SOMETHING_NEW'] = 'true'
  end

end

%w[dynamic cached static].each do |mode|
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
          App.inquires_about @type.upcase + (@type == "hash" ? "_" : ""), mode: @mode
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
