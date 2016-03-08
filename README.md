# PackRb

[![Circle CI](https://circleci.com/gh/manheim/pack_rb.svg?style=svg)](https://circleci.com/gh/manheim/pack_rb)

A gem for driving the [Packer][1] command line tool from within your Ruby project.

This gem was built against version ``0.9.0`` of [Packer][1]

## Pre-Requisites

You must have a version of [Packer][1] installed.

Go [download a copy][2] for your OS.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pack_rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pack_rb

## Usage

### With In Memory Template

```ruby
require 'pack_rb'
require 'json'

template = {
  variables: { foo: 'bar'},
  builders:   [
    {
      type:         'null',
      ssh_host:     '127.0.0.1',
      ssh_username: 'foo',
      ssh_password: 'bar'
    }
  ]
}.to_json

packer = PackRb::Packer.new(tpl: template, machine_readable: true)
packer.build(debug: true)
```

__Note:__ A plain old ruby hash can be used for template also. Just leave off
the JSON bits.

### With Template File

```ruby
require 'pack_rb'

packer = PackRb::Packer.new(tpl: 'config/template.json', machine_readable: true)
packer.build(debug: true)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec pack_rb` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pack_rb.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[1]: https://www.packer.io/
[2]: https://www.packer.io/downloads.html
