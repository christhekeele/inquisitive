Inquisitive
===========

Predicate methods for those curious about their datastructures.

Inquisitive allows you to interrogate objects about their contents with friendly, readable method chains. It's the logical conclusion of ActiveSupport's `StringInquirer`.

This library is extracted from several projects where I found myself building on the `Rails.env.production?` pattern: wrapping information from the `ENV` variable into more descriptive and flexible methods accessible from my main namespace. `Inquisitive::Environment` contains helper methods to further this end.

For all intents and purposes Inquisitive has no dependencies, doesn't pollute the global constant namespace with anything but `Inquisitive`, and doesn't touch any core classes. It uses ActiveSupport's `HashWithIndifferentAccess`, but will bootstrap itself with a minimal version extracted from ActiveSupport 4.0 if it cannot be found.

It also leans on `method_missing`, `dup`, and wrapper objects, so if your application is too inquisitive you might find it grinding to a halt. It's recommended to only use it to switch on a few core runtime environment variables. Don't serialize ActiveRecord attributes into it, is what I'm saying here.

Usage
-----

### String

`Inquisitive::String` tests equality:

```ruby
environment = Inquisitive::String.new 'development'
#=> "development"
environment.development?
#=> true
environment.not.development?
#=> false
```

### Array

`Inquisitive::Array` tests inclusion:

```ruby
supported_databases = Inquisitive::Array.new %w[mysql postgres sqlite]
#=> ["mysql", "postgres", "sqlite"]
supported_databases.postgres?
#=> true
supported_databases.sql_server?
#=> false
supported_databases.exclude.sql_server?
#=> true
```

### Hash

`Inquisitive::Hash` provides struct-like access to its values, wrapped in other inquisitive objects:

```ruby
stubbed = Inquisitive::Hash.new(
  authentication: true,
  in: 'development',
  services: %w[database api],
  ignorable: { junk: [ "" ] }
)
#=> {"authentication"=>true,
#=>  "in"=>"development",
#=>  "services"=>["database", "api"],
#=>  "ignorable"=>{"junk"=>[""]}}

stubbed.authentication?
#=> true
stubbed.registration?
#=> false
stubbed.services?
#=> true
stubbed.ignorable?
#=> false

stubbed.in.development?
#=> true
stubbed.in.production?
#=> false
stubbed.services.database?
#=> true
stubbed.services.sidekiq?
#=> false
```

`Inquisitive::Hash` also allows negation with the `no` method:

```ruby
config = Inquisitive::Hash.new(database: 'postgres')
#=> {"database"=>"postgres"}

config.database?
#=> true
config.no.database?
#=> false
config.api?
#=> false
config.no.api?
#=> true
```

### Inquisitive Environment

`Inquisitive::Environment` can be used in your modules and classes to more easily interrogate the `ENV` variable:

#### Strings

```ruby
ENV['ENVIRONMENT'] = "development"
class MyGame
  extend Inquisitive::Environment
  inquires_about 'ENVIRONMENT'
end

MyGame.environment
#=> "development"
MyGame.environment.development?
#=> true
MyGame.environment.production?
#=> false
```

#### Arrays

```ruby
ENV['SUPPORTED_DATABASES'] = "mysql,postgres,sqlite"
class MyGame
  extend Inquisitive::Environment
  inquires_about 'SUPPORTED_DATABASES'
end

MyGame.supported_databases
#=> ["mysql", "postgres", "sqlite"]
MyGame.supported_databases.sqlite?
#=> true
MyGame.supported_databases.sql_server?
#=> false
```

#### Hashes

```ruby
ENV['STUB_AUTHENTICATION'] = 'true'
ENV['STUB_IN'] = "development"
ENV['STUB_SERVICES'] = "database,api"
class MyGame
  extend Inquisitive::Environment
  inquires_about 'STUB_'
end

MyGame.stub.authentication?
#=> true
MyGame.stub.registration?
#=> false
MyGame.stub.in.development?
#=> true
MyGame.stub.in.production?
#=> false
MyGame.stub.services.exclude.sidekiq?
#=> true
MyGame.stub.services.sidekiq?
#=> false
```

#### Naming

You can name your environment inquirers with `:with`:

```ruby
ENV['ENVIRONMENT'] = "development"
class MyGame
  extend Inquisitive::Environment
  inquires_about 'ENVIRONMENT', with: :env
end

MyGame.env
#=> "development"
MyGame.env.development?
#=> true
MyGame.env.production?
#=> false
```

#### Presence

Environment inquirers can have explicit presence checks, circumventing a common pitfall when reasoning about environment variables. Borrowing from the example above:

```ruby
ENV['STUB_AUTHENTICATION'] = 'false'
class MyGame
  extend Inquisitive::Environment
  inquires_about 'STUB_'
end

MyGame.stub.authentication
#=> "false"
MyGame.stub.authentication?
#=> true
MyGame.stub.authentication.true?
#=> false
```

It's common to use the presence of environment variables as runtime booleans. This is frequently done by setting the environment variable to the string `"true"` when you want it to be true, and not at all otherwise. As demonstrated, this pattern can lead to ambiguity when the string is other values.

By default such variables will be parsed as an `Inquisitive::String`, so predicate methods will return true whatever their contents, as long as they exist. You can bind the predicate method tighter to an explicit value if you prefer:

```ruby
ENV['STUB_AUTHENTICATION'] = 'false'
ENV['STUB_REGISTRATION'] = 'true'
class MyGame
  extend Inquisitive::Environment
  inquires_about 'STUB_AUTHENTICATION', present_if: 'true'
  inquires_about 'STUB_REGISTRATION', present_if: 'true'
end

MyGame.stub_authentication
#=> "false"
MyGame.stub_authentication?
#=> false

MyGame.stub_registration
#=> "true"
MyGame.stub_registration?
#=> true
```

This only works on top-level inquirers, so there's no way to get our nested `MyGame.stubbed.authentication?` to behave as expected (currently).

The `present_if` check uses `===` under the covers for maximum expressiveness, so you can also use it to match against regexs and other constructs.

#### Inquiry mode

Environment inquirers have three configurable modes, defaulting to `:dynamic`:

```ruby
class MyGame
  extend Inquisitive::Environment
  inquires_about 'STUB_', mode: %i[dynamic cached static].sample
end
```

- **Dynamic**

    Environment inquiries parse `ENV` on every invocation.

    Use if you're manipulating the environment in between invocations, so `Inquisitive` can pick up on new values, detect changes between string or array notation, and discover new keys for hash notation.

- **Cached**

    Environment inquiries check `ENV` on their first invocation, and re-use the response in future invocations.

    Use if you're loading the module with environment inquiry methods before you've finished preparing your environment.

- **Static**

    Environment inquiries use the contents of `ENV` at the moment `inquires_about` was invoked.

    Use if your application is well-behaved and doesn't go mucking around with the environment at runtime.

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
