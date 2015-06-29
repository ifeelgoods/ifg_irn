# IfgIrn

`IRN` are simple string format that identify a resource or a set of resource. It was heavily inspired by Amazon ARN identifier.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ifg_irn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ifg_irn

## Usage

An IRN can either uniquely identifiy a resource

```ruby
a_reward = Irn.new('irn:ifeelgoods:rewards:1234')
```

Or a set of resources. Such are called wildcard irn

```ruby
rewards = Irn.new('irn:ifeelgoods:rewards:*')
```

An IRN is similar to a path. An irn match another if they are the same

```ruby
a_reward.match(Irn.new('irn:ifeelgoods:rewards:1234'))
true
```

Or the latter is contained in the first one

```ruby
rewards.match?(a_reward)
true
  ```

All descendents irn are matched. the `strict` options allow to restrict the matching to immediate children

```ruby
rewards.match?(Irn.new('irn:ifeelgoods:rewards:1234:variants:3'))
true

rewards.match?(Irn.new('irn:ifeelgoods:rewards:1234:variants:3', strict: true))
false
```

The matching part of the irn can be extracted using the match method

```ruby
match_result = rewards.match(a_reward)
match_result.data
'1234'
```

The bind method create a new matching irn

```ruby
irn = rewards.bind('9999')
puts irn
irn:ifeelgoods:rewards:9999
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ifeelgoods/ifg_irn.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

