# A9n

[![Build status](https://secure.travis-ci.org/knapo/a9n.png)](https://travis-ci.org/knapo/a9n)

Simple tool for managing ruby/rails application configurations.

## Installation

Add this line to your application's Gemfile:

    gem 'a9n'

And then execute:

    $ bundle

Add `configuration.yml.example` and/or `configuration.yml` file to config directory.

In your `application.rb` load configuration with:

    A9n.load

## Usage

    A9n.app_host

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
