Rh
=====
Fast Ruby documentation lookup

[<img src="https://secure.travis-ci.org/tombenner/rh.png" />](http://travis-ci.org/tombenner/rh)

Overview
--------

Rh lets you easily look up Ruby documentation about classes, modules, and methods from the command line:

```bash
$ rh Array
$ rh Enumerable#chunk
$ rh Time.gm
$ rh with_index
```

If you're not sure where a method is defined, you can just enter it. If it's only defined in one class/module, that documentation will be shown. Otherwise, you'll get a choice:

```bash
$ rh cycle
Did you mean?
  0. Array#cycle
  1. Enumerable#cycle
Enter a number:
```

Everything from the core API and the standard library is supported, and documentation is shown on [ruby-doc.org](http://www.ruby-doc.org/) in a browser. Rh might eventually show documentation in the shell instead.

Rh shows documentation for the version of Ruby that's running it.

Installation
------------

```bash
gem install rh
```

Usage
-----

### Formats

#### Classes/modules:

```bash
$ rh Array
```

#### Class methods:

```bash
$ rh Time.gm
$ rh Time::gm
$ rh .gm
$ rh ::gm
```

#### Instance methods:

```bash
$ rh Enumerable#chunk
$ rh '#chunk'
```

#### Class methods and instance methods:

```bash
$ rh parse
```

License
-------

Rh is released under the MIT License. Please see the MIT-LICENSE file for details.
