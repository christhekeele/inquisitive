Inquisitive
===========

> **Predicate methods for those curious about their datastructures.**

Inquisitive provides String, Array, and Hash subclasses with dynamic predicate methods that allow you to interrogate the most common Ruby datastructures in a readable, friendly fashion. It's the inevitable evolution of ActiveSupport's `StringInquirer`.

It also allows you to auto-instanciate and read inquisitive datastructures straight from your `ENV` hash through the `Inquisitive::Environment` module.

Inquisitive will try to use ActiveSupport's `HashWithIndifferentAccess`, but if that cannot be found it will bootstrap itself with a minimal, well-tested version extracted from ActiveSupport 4.0.

Installation
------------

To add to your project:

```bash
$ echo "gem 'inquisitive'" >> Gemfile
$ bundle install
```

Otherwise:

```bash
gem install inquisitive
```

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

`Inquisitive::Environment` can be used in your modules and classes to more easily interrogate `ENV` variables with inquisitive objects:

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

The `present_if` check uses `===` under the covers for maximum expressiveness, so you can also use it to match against regexs, classes, and other constructs.

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
