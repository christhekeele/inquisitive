Inquisitive
===========

> **Predicate methods for those curious about their datastructures.**

Synopsis
--------

Inquisitive provides String, Array, and Hash subclasses with dynamic predicate methods that allow you to interrogate the most common Ruby datastructures in a readable, friendly fashion. It's the inevitable evolution of ActiveSupport's [`StringInquirer`](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/string_inquirer.rb).

It also allows you to elegantly interrogate your `ENV` hash through the `Inquisitive::Environment` module.

Inquisitive will try to use ActiveSupport's [`HashWithIndifferentAccess`](guides.rubyonrails.org/active_support_core_extensions.html#indifferent-access), but if that cannot be found it will bootstrap itself with a minimal, well-tested version extracted from [ActiveSupport 4.0](https://github.com/rails/rails/blob/4-0-stable/activesupport/lib/active_support/hash_with_indifferent_access.rb).

Inquisitive is tested against all maintained versions of Ruby and ActiveSupport.

--------------------------------------------------------------------------------

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

|         :thumbsup:         |  [Continuous Integration][status]   |        [Test Coverage][coverage]         |
|:--------------------------:|:-----------------------------------:|:----------------------------------------:|
|      [Master][master]      |   ![Build Status][master-status]    |   ![Coverage Status][master-coverage]    |
| [Development][development] | ![Build Status][development-status] | ![Coverage Status][development-coverage] |

--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------

Usage
-----


### Helpers

You can coerce any object to a supported Inquisitive equivalent with the Inquisitive coercion helpers:

```ruby
Inquisitive.coerce('foo').class
#=> Inquisitive::String
Inquisitive.coerce(1).class
#=> Integer

Inquisitive['foo'].class
#=> Inquisitive::String
Inquisitive[1].class
#=> Integer

Inquisitive.coerce!('foo').class
#=> Inquisitive::String
Inquisitive.coerce!(1).class
#=> NameError
```

You can check if any object appears to be present with the Inquisitive presence helper:

```ruby
Inquisitive.present? 'foo'
#=> true
Inquisitive.present? %i[foo]
#=> true
Inquisitive.present? {foo: :bar}
#=> true
Inquisitive.present? 0
#=> true
Inquisitive.present? true
#=> true

Inquisitive.present? ''
#=> false
Inquisitive.present? Array.new
#=> false
Inquisitive.present? Hash.new
#=> false
Inquisitive.present? false
#=> false
Inquisitive.present? nil
#=> false
Inquisitive.present? Inquisitive::NilClass.new
#=> false
```

Finally, you can check if any object is explicitly an Inquisitive object with the Inquisitive object helper:

```ruby
nil_object = nil
Inquisitive.object? nil_object
#=> false
Inquisitive.object? Inquisitive[nil_object]
#=> true
Inquisitive.object? Inquisitive::NilClass.new nil_object
#=> true

string = 'foo'
Inquisitive.object? string
#=> false
Inquisitive.object? Inquisitive[string]
#=> true
Inquisitive.object? Inquisitive::String.new string
#=> true

array = %i[foo]
Inquisitive.object? array
#=> false
Inquisitive.object? Inquisitive[array]
#=> true
Inquisitive.object? Inquisitive::Array.new array
#=> true

hash = {foo: :bar}
Inquisitive.object? hash
#=> false
Inquisitive.object? Inquisitive[hash]
#=> true
Inquisitive.object? Inquisitive::Hash.new hash
#=> true
```


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
  ignorable: { junk: [ '' ] }
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

This custom `Inquisitive::NilClass` comes with a few caveats, read the section below to understand them.


### NilClass

`Inquisitive::NilClass` is a black-hole null object that respects the Inquisitive interface, allowing you to inquire on non-existant nested datastructures as if there was one there, negated methods included:

```ruby
nillish = Inquisitive::NilClass.new
#=> nil

nillish.nil?
#=> true
nillish.present?
#=> false


nillish.predicate?
#=> false
nillish.access
#=> nil
nillish.deep.access
#=> nil
nillish.not.access
#=> true
nillish.exclude.access
#=> true
nillish.no.access
#=> true
```

**Be warned**: since Ruby doesn't allow subclassing `NilClass` and provides no boolean-coercion interface, `Inquisitive::NilClass` **will** appear truthy. I recommend using built-in predicates (`stubbed.authentication? && ...`), presence predicates with ActiveSupport (`stubbed.authentication.present? && ...`), Inquisitive's presence utility (`Inquisitive.present?(stubbed.authentication) && ...`) or nil predicates (`stubbed.authentication.nil? || ...`) in boolean chains. Also note that for `Inquisitive::Hash` access, `stubbed.fetch(:authentication, ...)` behaves as expected.


### Inquisitive Environment

`Inquisitive::Environment` can be used in your modules and classes to more easily interrogate `ENV` variables with inquisitive objects:

#### Strings

```ruby
ENV['ENVIRONMENT'] = 'development'
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
ENV['SUPPORTED_DATABASES'] = 'mysql,postgres,sqlite'
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
ENV['STUB__AUTHENTICATION']  = 'true'
ENV['STUB__IN']              = 'development'
ENV['STUB__SERVICES']        = 'database,api'
ENV['STUB__API__PROTOCOL']   = 'https'
ENV['STUB__API__SUBDOMAINS'] = 'app,web,db'
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

#### Defaults

You can set default values for your environment inquirers.

```ruby
class MyApp
  extend Inquisitive::Environment
  inquires_about 'ENV', default: 'production'
end

MyApp.env?
#=> true
MyApp.env.production?
#=> true
```

#### Naming

You can also give your environment inquirers custom names:

```ruby
ENV['ENVIRONMENT'] = 'development'
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

#### Presence

Environment inquirers can have explicit presence checks, circumventing a common pitfall when reasoning about environment variables. Borrowing from the example above:

```ruby
ENV['STUB__AUTHENTICATION'] = 'false'
class MyApp
  extend Inquisitive::Environment
  inquires_about 'STUB'
end

MyApp.stub.authentication
#=> "false"
MyApp.stub.authentication?
#=> true
MyApp.stub.authentication.true?
#=> false
```

It's common to use the presence of environment variables as runtime booleans. This is frequently done by setting the environment variable to the string `"true"` when you want it to be true, and not at all otherwise. As demonstrated, this pattern can lead to ambiguity when the string is other values.

By default such variables will be parsed as an `Inquisitive::String`, so predicate methods will return true whatever their contents, as long as they exist. You can bind the predicate method tighter to an explicit value if you prefer:

```ruby
ENV['STUB_AUTHENTICATION'] = 'false'
ENV['STUB_REGISTRATION']   = 'true'
class MyApp
  extend Inquisitive::Environment
  inquires_about 'STUB_AUTHENTICATION', present_if: 'true'
  inquires_about 'STUB_REGISTRATION',   present_if: 'true'
end

MyApp.stub_authentication
#=> "false"
MyApp.stub_authentication?
#=> false

MyApp.stub_registration
#=> "true"
MyApp.stub_registration?
#=> true
```

This only works on top-level inquirers, so there's no way to get our nested `MyApp.stubbed.authentication?` to behave as expected. Prefer `MyApp.stubbed.authentication.true?` instead.

The `present_if` check uses `===` under the covers for maximum expressiveness, so you can also use it to match against regexs, classes, and other constructs.

##### Truthy Strings

`Inquisitive::Environment.truthy` contains a regex useful for trying to read truthy values from string environment variables.

```ruby
ENV['NO']        = 'no'
ENV['YES']       = 'yes'
ENV['TRUTHY']    = 'TrUe'
ENV['FALSEY']    = 'FaLsE'
ENV['BOOLEAN']   = '1'
ENV['BOOLENOPE'] = '0'
class MyApp
  extend Inquisitive::Environment
  inquires_about 'NO',        present_if: truthy
  inquires_about 'YES',       present_if: truthy
  inquires_about 'TRUTHY',    present_if: truthy
  inquires_about 'FALSEY',    present_if: truthy
  inquires_about 'BOOLEAN',   present_if: truthy
  inquires_about 'BOOLENOPE', present_if: truthy
end

MyApp.no?
#=> false
MyApp.yes?
#=> true

MyApp.truthy?
#=> true
MyApp.falsey?
#=> false

MyApp.boolean?
#=> true
MyApp.boolenope?
#=> false
```

--------------------------------------------------------------------------------

Origins
-------

The idea for Inquisitive originated with [this pull request](https://github.com/rails/rails/pull/12587), as I was going through a complicated Rails application and making it more 12-factor friendly by extracting much of the configuration into environment variables.

By the end of my effort, my configuration was substantially more *centralized* and *standardized*, but far more *complicated*. These complications arose in two places: adding, managing, permuting, and documenting my `.env` file consumed by [dotenv](https://github.com/bkeepers/dotenv); and organizing, parsing, and switching on those values injected into the `ENV`.

My pull request, and later Inquisitive, was extracted from my treatment of the latter complication. My solution to the former, [starenv](https://github.com/christhekeele/starenv), was a generally more complicated beast.

--------------------------------------------------------------------------------

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
