# A9n

[![Gem Version](https://badge.fury.io/rb/a9n.svg)][gem_version]
[![Build status](https://secure.travis-ci.org/knapo/a9n.svg)][travis]
[![Maintainability](https://api.codeclimate.com/v1/badges/566c2c51f1a383d18be8/maintainability)](https://codeclimate.com/github/knapo/a9n/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/566c2c51f1a383d18be8/test_coverage)](https://codeclimate.com/github/knapo/a9n/test_coverage)

[gem_version]: https://rubygems.org/gems/a9n
[travis]: http://travis-ci.org/knapo/a9n
[codeclimate]: https://codeclimate.com/github/knapo/a9n
[coverage]: https://codeclimate.com/github/knapo/a9n

A9n is a simple tool to keep ruby/rails apps configuration maintanable and verifiable. It supports Rails 6+ and Ruby 2.7+.

Why it's named a9n? It's a numeronym for application (where 9 stands for the number of letters between the first **a** and last **n**, similar to i18n or l10n).

## Installation

Add this line to your application's Gemfile:

    gem 'a9n'

And then execute:

    $ bundle

Add `a9n.yml.example` and/or `a9n.yml` file into the config
directory. When none fo these files exists, `A9n::MissingConfigurationFile`
exception is thrown. You can also use `configuration.yml(.example)`.
If both file exist, content of `a9n.yml` is validated. It means that
all keys existing in example file must exist in local file - in case of missing
keys `A9n::MissingConfigurationVariablesError` is thrown with the explanation what is missing.

Set application root and load configuration by adding to your `application.rb` or `environment.rb` right
after budler requires:

    A9n.root = File.expand_path('..', __dir__)
    A9n.load

This step is not required ,if you don't use `a9n` in the environment settings or initializers.
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

If you want to split configuration, you can use multiple files. All files from `config/a9n` are loaded by default, but you may pass custom paths as an argument to `A9n.load` e.g. `A9n.load('config/aws.yml', 'config/mail.yml')`. In such cases config items are accessible through the scope consistent with the file name.

E.g. if you have `config/a9n/mail.yml`:

     defaults:
       email_from: 'knapo@knapo.net'
       delivery_method: 'smtp'

You can access it by:

     A9n.mail.email_from # => `knapo@knapo.net`
     A9n.mail.delivery_method # => `smtp`

## Setting variables manually

You can set variables manually using `A9n.set` method

     A9n.set(:app_host, "localhost:3000")
     A9n.app_host # => `localhost:3000`

To reload/restore configuration:

     A9n.load

## Mapping ENV variables

Sometimes, you don't want to store a single secret value in the repo and you prefer having it in ENV variable. You can easily map it using `:env` symbol as a value:

     production:
       access_token: :env

## Capistrano

If you use capistrano and you feel safe enough to keep all your instance ( staging, production) configuration in the repository, you may find it useful to use capistrano extensions.
Just add an instance configuration file e.g. `configuration.yml.staging`, `configuration.yml.production` (NOTE: file extension must be consistent with the capistrano stage) and add

    require 'a9n/capistrano'

to your Capfile. This way `a9n.yml.<stage>` overrides `a9n.yml` on each deploy.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

