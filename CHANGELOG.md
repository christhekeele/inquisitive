Changes to Inquisitive
======================

> **Please consult this file when upgrading Inquisitive for important information on bugfixes, new features, and backwards incompatible changes.**

Starting with **[2.0.0](#2.0.0)**, Inquisitive follows [symantic versioning](symver.org) to help inform you of the implications of upgrades.

Releases
--------

[4.0.0]: https://github.com/christhekeele/inquisitive/tree/4.0.0

[2.0.1]: https://github.com/christhekeele/inquisitive/tree/2.0.1
[2.0.0]: https://github.com/christhekeele/inquisitive/tree/2.0.0

[1.2.0]: https://github.com/christhekeele/inquisitive/tree/f314eaf84f7c3d9a2d56ae684d031dd81d2f7b85

- [4.0.0](#4.0.0)
- [2.0.0](#2.0.0)
- [1.2.0](#1.2.0)

4.0.0 - [2015.03.06][4.0.0]
---------------------------

Inquisitive has seen several new versions since this Changelog has been updated, all aimed at simplifying the codebase and adding a few features I've long desired. These goals have been accomplished with version 4.0.0, so now's as good as time as any to enumerate the changes. It's also a great time to upgrade!

- `ruby-1.9.3`: **support dropped**

  Support for ruby 1.9.3 has been dropped, as it has reached end of life. Syntactically 4.0.0 should still work with 1.9.3, but that's no longer assured and may change. 1.9.3 is still a part of the build matrix but failures are allowed. Refer to the continuous integration to see if it's still viable.

- `Inquisitive::Environment.inquires_about`: **modes dropped**

  Environment inquiry modes no longer exist; all lookups are dynamic. While cached inquiries are about 3 times faster each inquiry takes a fraction of a percent of a millisecond so the speed up is negligible. More importantly, dynamic-by-default follows the principle of least surprise. Between the two there's no reason offer other modes. The option is now silently ignored when declaring inquirers, but your application's behavior may change if you were relying on caching by default.

- `Inquisitive::NilClass`: **null objects now available**

  While `Inquisitive::NilClass`s don't act falsey in boolean checks, they're useful wherever you may have been expecting another Inquisitive object, because they respond to methods like all other Inquisitive objects. It's also a "black hole" object, so it'll return itself on deep inquiries to mock nested inquisitive datastructures:

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

- `Inquisitive::Hash`: **missing keys return `Inquisitive::NilClass` instances**

  This allows for further method chaining when you anticipate nested datastructures where there aren't any.

- `Inquisitive::Environment.inquires_about`: **default values**

  Environment inquirers can now set default values:

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

- `Inquisitive::Environment.inquires_about`: **empty values**

  Environment inquirers without defaults will return `Inquisitive::NilClass` instances for empty environment variables to allow method chains as if you had nested datastructures.

- `Inquisitive::Environment.inquires_about`: **nested hashes**

  You can now construct nested hashes from environment variables with multiple `__`s in their names:

  ```ruby
  ENV['STUB__API__PROTOCOL']   = 'https'
  ENV['STUB__API__SUBDOMAINS'] = 'app,web,db'
  class MyApp
    extend Inquisitive::Environment
    inquires_about 'STUB'
  end

  MyApp.stub
  #=> {api: {protocol: "https", subdomains: ["app", "web", "db"]}}
  MyApp.stub.api.protocol.http?
  #=> false
  MyApp.stub.api.subdomains.web?
  #=> true
  ```

Refer to the documentation in the README.md for a through overview and more examples.

2.0.1 - [2014.09.24][2.0.1]
---------------------------

### Non-breaking

- `Inquisitive::Environment.truthy`: **helper regex**

  The `truthy` method provides an easy way to handle various command-line representations of truthiness.


2.0.0 - [2014.06.19][2.0.0]
---------------------------

### Breaking

- `Inquisitive::Environment`: **hash detection**

  Previously `inquires_about` needed a special syntax to detect when you want to parse a group of environment variables as a hash. This was accomplished by leaving a trailing `_` in the declaration, such as:

  ```ruby
  ENV['PREFIX_KEY1'] = "value1"
  ENV['PREFIX_KEY2'] = "value2"
  module Mine
    extend Inquisitive::Environment
    inquires_about 'PREFIX_'
  end
  Mine.prefix
  #=> { 'key1' => 'value1', 'key2' => 'value2' }
  ```

  Now it auto-detects hash groupings by looking for a double-`_` in the key itself:

  ```ruby
  ENV['PREFIX__KEY1'] = "value1"
  ENV['PREFIX__KEY2'] = "value2"
  module Mine
    extend Inquisitive::Environment
    inquires_about 'PREFIX'
  end
  Mine.prefix
  #=> { 'key1' => 'value1', 'key2' => 'value2' }
  ```

  Nested hashes (through multiple `__`'s) are not yet supported.

- `Inquisitive::Environment`:  **default modes**

  Previously the default mode was `:dynamic`. This was mostly to prevent unexpected behaviour for newcomers.

  Now `:static` is the default. This is because `Inquisitive::Environment` is meant to be loaded immediately after a boot script that prepares your environment variables, and queried often later. `:static` optimizes to this usecase.

  To reproduce the old behaviour, you must explicitly pass `mode: :dynamic` each to `inquires_about` invocation. Alternatively, `mode: :lazy` might be a viable way to get the benefits of `:static` without refactoring your boot process.

### Non-breaking

- `Inquisitive::Environment`: **cached mode now lazy mode**

  The `:cached` environment mode is now known as `:lazy`. This is backwards compatible because all logic handling modes explicitly checks for `:static` or `:dynamic`, so any other named mode has the same behaviour as `:lazy`.

1.2.0 - [2013.11.21][1.2.0]
---------------------------

Everything to date.
