# A9n

[![Build status](https://secure.travis-ci.org/knapo/a9n.png)](https://travis-ci.org/knapo/a9n)

Simple tool for managing ruby/rails application configurations.

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

Load configuration by adding to youre `application.rb` or `environment.rb`

    A9n.load

This step is not required, but recommended, as it configuration is loaded and
verified on evironment load.

## Usage

You can access any variable defined in configuration files but delegating it to 
`A9n`. E.g:

    production:
      app_host: 'http://knapo.net'

is accessible by:

    A9n.app_host

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
