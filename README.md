# A9n

[![Gem Version](https://badge.fury.io/rb/a9n.png)][gem_version]
[![Build status](https://secure.travis-ci.org/knapo/a9n.png)][travis]
[![Code Climate](https://codeclimate.com/github/knapo/a9n.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/knapo/a9n/badge.png?branch=master)][coveralls]

[gem_version]: https://rubygems.org/gems/a9n
[travis]: http://travis-ci.org/knapo/a9n
[codeclimate]: https://codeclimate.com/github/knapo/a9n
[coveralls]: https://coveralls.io/r/knapo/a9n

A9n is a simple tool for managing extra configuration in ruby/rails apps. It supports Rails 2.x, 3.x, 4.x and Ruby 1.9, 2.0. 2.1. Ruby 1.8 is not supported since version 0.1.2.

## Installation

Add this line to your application's Gemfile:

    gem 'a9n'

And then execute:

    $ bundle

Add `configuration.yml.example` and/or `configuration.yml` file into the config
directory. When none fo these files exists, `A9n::MissingConfigurationFile`
exception is thrown.
If both file exist, content of `configuration.yml` is validated. It means that
all keys existing in example file must exist in base file - in case of missing
keys`A9n::MissingConfigurationVariables` is thrown with information about
missing keys.

Set application root and load configuration by adding to your `application.rb` or `environment.rb` right
after budler requires:

    A9n.root = File.expand_path('../..', __FILE__)
    A9n.load

It works with `Rails` by default. If you want to use `A9n` with non-rails app
you may need to tell that to A9n by:

    A9n.local_app = MyApp

## Usage

You can access any variable defined in configuration files by delegating it to
`A9n`. E.g:

    defaults:
      email_from: 'no-reply@knapo.net'
    production:
      app_host: 'knapo.net'
    development:
      app_host: 'localhost:3000'

is accessible by:

    A9n.app_host   # => `knapo.net` in production and `localhost:3000` in development
    A9n.email_from # => `no-reply@knapo.net` in both envs

## Custom and multiple configuration files

If you want to scope configuration you may split to multiple files. All files from `config/a9n` are loaded by default, but you may pass custom paths as an argument to `A9n.load` e.g. `A9n.load('lib/facebook/api.yml', 'config/mongoid.yml')`. In such cases config items are accessialbe via scope consistient with the file name. 

E.g. if you have `config/a9n/mandrill.yml`:
     
     defaults:
       username: "joe"
       api_key: "1234asdf"

you can access it by:

     A9n.mandrill.username # => `joe`
     A9n.mandrill.api_key # => `1234asdf`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

