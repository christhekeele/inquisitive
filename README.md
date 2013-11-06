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
supported_databases.include.postgres?
#=> true
supported_databases.include.sql_server?
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
stubbed.services.include.database?
#=> true
stubbed.services.include.sidekiq?
#=> false
```

### Inquisitive Environment

`Inquisitive::Environment` can be used in your modules and classes to more easily interrogate the `ENV` variable:

#### Strings

```ruby
ENV['GAME_ENV'] = "development"
class MyGame
  extend Inquisitive::Environment
  inquires_about 'GAME_ENV', with: :environment
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
ENV['ENABLED_DBS'] = "mysql,postgres,sqlite"
class MyGame
  extend Inquisitive::Environment
  inquires_about 'ENABLED_DBS', with: :supported_databases
end

MyGame.supported_databases
#=> ["mysql", "postgres", "sqlite"]
MyGame.supported_databases.include.sqlite?
#=> true
MyGame.supported_databases.include.sql_server?
#=> false
```

#### Hashes

```ruby
ENV['STUB_AUTHENTICATION'] = 'true'
ENV['STUB_IN'] = "development"
ENV['STUB_SERVICES'] = "database,api"
class MyGame
  extend Inquisitive::Environment
  inquires_about 'STUB', with: :stubbed
end

MyGame.stubbed.authentication?
#=> true
MyGame.stubbed.registration?
#=> false
MyGame.stubbed.in.development?
#=> true
MyGame.stubbed.in.production?
#=> false
MyGame.stubbed.services.exclude.sidekiq?
#=> true
MyGame.stubbed.services.include.sidekiq?
#=> false
```

#### Inquiry mode

Environment inquires have three configurable modes, defaulting to `:dynamic`:

```ruby
class MyGame
  extend Inquisitive::Environment
  inquires_about 'STUB', with: :stubbed, mode: %i[dynamic cached static].sample
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
