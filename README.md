Inquisitive
===========

> **Predicate methods for those curious about their datastructures.**



Synopsis
--------

Inquisitive provides String, Array, and Hash subclasses with dynamic predicate methods that allow you to interrogate the most common Ruby datastructures in a readable, friendly fashion. It's the inevitable evolution of ActiveSupport's `StringInquirer`.

It also allows you to auto-instanciate and read inquisitive datastructures straight from your `ENV` hash through the `Inquisitive::Environment` module.

Inquisitive will try to use ActiveSupport's `HashWithIndifferentAccess`, but if that cannot be found it will bootstrap itself with a minimal, well-tested version extracted from ActiveSupport 4.0.



Status
------

[status]:   https://travis-ci.org/christhekeele/inquisitive
[coverage]: https://rawgit.com/christhekeele/inquisitive/master/coverage/index.html

[version]:       https://rubygems.org/gems/inquisitive/versions
[version-image]: https://badge.fury.io/rb/inquisitive@2x.svg

[quality]:       https://codeclimate.com/github/christhekeele/inquisitive
[quality-image]: https://img.shields.io/codeclimate/github/christhekeele/inquisitive.svg

[dependencies]:       https://gemnasium.com/christhekeele/inquisitive
[dependencies-image]: http://img.shields.io/gemnasium/christhekeele/inquisitive.svg

[master]:          https://github.com/christhekeele/inquisitive/tree/master
[master-status]:   https://img.shields.io/travis/christhekeele/inquisitive/master.svg
[master-coverage]: https://img.shields.io/coveralls/christhekeele/inquisitive/master.svg

[development]:          https://github.com/christhekeele/inquisitive/tree/development
[development-status]:   https://img.shields.io/travis/christhekeele/inquisitive/development.svg
[development-coverage]: https://img.shields.io/coveralls/christhekeele/inquisitive/development.svg

[![Version][version-image]][version] [![Quality][quality-image]][quality] [![Dependencies][dependencies-image]][dependencies]

|          :thumbsup:        |   [Continuous Integration][status]  |           [Test Coverage][coverage]      |
|:--------------------------:|:-----------------------------------:|:----------------------------------------:|
| [Master][master]           | ![Build Status][master-status]      | ![Coverage Status][master-coverage]      |
| [Development][development] | ![Build Status][development-status] | ![Coverage Status][development-coverage] |



Installation
------------

To add to your project:

```bash
$ echo "gem 'inquisitive'" >> Gemfile
$ bundle install
```

Otherwise:

```bash
$ gem install inquisitive
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
  api: {protocol: 'https', subdomains: %w[app web db]},
  ignorable: { junk: [ "" ] }
)
#=> {"authentication"=>true,
#=>  "in"=>"development",
#=>  "services"=>["database", "api"],
#=>  "api"=>{"protocol"=>"https", "subdomains"=>["app", "web", "db"]},
#=>  "ignorable"=>{"junk"=>[""]}}

stubbed.authentication?
#=> true
stubbed.registration?
#=> false
stubbed.services?
#=> true
stubbed.api?
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

stubbed.api.protocol?
#=> true
stubbed.api.protocol.http?
#=> false
stubbed.api.domains.web?
#=> true
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

Empty keys and nil values become instances of `Inquisitive::NilClass`, which is a black-hole null object that respects the Inquisitive interface, allowing you to inquire on non-existant nested datastructures as if there was one there, negated methods included:

```ruby
stubbed = Inquisitive::Hash.new
#=> {}

# We can query it as if we assumed we had:
#=> {"authentication"=>true,
#=>  "in"=>"development",
#=>  "services"=>["database", "api"],
#=>  "api"=>{"protocol"=>"https", "subdomains"=>["app", "web", "db"]}}

stubbed.authentication?
#=> false
stubbed.registration?
#=> false
stubbed.services?
#=> false
stubbed.api?
#=> false
stubbed.ignorable?
#=> false
stubbed.no.ignorable?
#=> true

stubbed.in.development?
#=> false
stubbed.in.production?
#=> false
stubbed.in.not.production?
#=> true

stubbed.services.database?
#=> false
stubbed.services.sidekiq?
#=> false
stubbed.services.exclude.sidekiq?
#=> true

stubbed.api.protocol?
#=> false
stubbed.api.no.protocol?
#=> true
stubbed.api.protocol.http?
#=> false
stubbed.api.domains.web?
#=> false
```


### Inquisitive Environment

`Inquisitive::Environment` can be used in your modules and classes to more easily interrogate `ENV` variables with inquisitive objects:

#### Strings

```ruby
ENV['ENVIRONMENT'] = "development"
class MyApp
  extend Inquisitive::Environment
  inquires_about 'ENVIRONMENT'
end

MyApp.environment
#=> "development"
MyApp.environment.development?
#=> true
MyApp.environment.production?
#=> false
```

#### Arrays

Arrays are recognized when environment variables contain commas:

```ruby
ENV['SUPPORTED_DATABASES'] = "mysql,postgres,sqlite"
class MyApp
  extend Inquisitive::Environment
  inquires_about 'SUPPORTED_DATABASES'
end

MyApp.supported_databases
#=> ["mysql", "postgres", "sqlite"]
MyApp.supported_databases.sqlite?
#=> true
MyApp.supported_databases.sql_server?
#=> false
```

#### Hashes

Hashes are recognized when environment variables names contain double underscores:

```ruby
ENV['STUB__AUTHENTICATION'] = 'true'
ENV['STUB__IN'] = "development"
ENV['STUB__SERVICES'] = "database,api"
ENV['STUB__API__PROTOCOL'] = "https"
ENV['STUB__API__SUBDOMAINS'] = "app,web,db"
class MyApp
  extend Inquisitive::Environment
  inquires_about 'STUB'
end

MyApp.stub.authentication?
#=> true
MyApp.stub.registration?
#=> false
MyApp.stub.in.development?
#=> true
MyApp.stub.in.production?
#=> false
MyApp.stub.services.exclude.sidekiq?
#=> true
MyApp.stub.services.sidekiq?
#=> false
MyApp.stub.api.protocol.http?
#=> false
MyApp.stub.api.subdomains.web?
#=> true
```

#### Naming

You can name your environment inquirers with `:with`:

```ruby
ENV['ENVIRONMENT'] = "development"
class MyApp
  extend Inquisitive::Environment
  inquires_about 'ENVIRONMENT', with: :env
end

MyApp.env
#=> "development"
MyApp.env.development?
#=> true
MyApp.env.production?
#=> false
```

#### Inquiry mode

Environment inquirers have three configurable modes, defaulting to `:static`.

```ruby
class MyApp
  extend Inquisitive::Environment
  inquires_about 'STUB', mode: %i[dynamic lazy static].sample
end
```

- **Dynamic**

    Environment inquiries parse `ENV` on every invocation.

    Use if you're manipulating the environment in between invocations, so `Inquisitive` can pick up on new values, detect changes between string or array notation, and discover new keys for hash notation.

- **Lazy**

    Environment inquiries check `ENV` on their first invocation, and re-use the response in future invocations.

    Use if you're loading the module with environment inquiry methods before you've finished preparing your environment.

- **Static**

    Environment inquiries use the contents of `ENV` at the moment `inquires_about` was invoked.

    Use if your application is well-behaved and doesn't go mucking around with the environment at runtim.



Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
