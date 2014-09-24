Changes to Inquisitive
======================

> **Please consult this file when upgrading Inquisitive for important information on bugfixes, new features, and backwards incompatible changes.**

Starting with **[2.0.0](#2.0.0)**, Inquisitive follows [symantic versioning](symver.org) to help inform you of the implications of upgrades.

Releases
--------

[2.0.1]: https://github.com/christhekeele/inquisitive/tree/2.0.1
[2.0.0]: https://github.com/christhekeele/inquisitive/tree/2.0.0
[1.2.0]: https://github.com/christhekeele/inquisitive/tree/f314eaf84f7c3d9a2d56ae684d031dd81d2f7b85

- [2.0.0](#2.0.0)
- [1.2.0](#1.2.0)

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
