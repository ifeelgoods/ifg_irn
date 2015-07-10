# IfgIrn

`IRN` are simple string format that identify a resource or a set of resource.
It was heavily inspired by Amazon ARN identifier. Irn can be optionally
validated against a Schema.

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

### Working with Irn

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

By default all descendents irns are matched. The `strict` options allow to
restrict the matching to immediate children only.

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

### Validating Irn with Schema

An Irn Schema describe the structure that must follow an irn to be valid.
Consider you have a set of resources that must be arranged by organization,
country and service. Such constraint can be expressed by the schema
`irn:?org:?country:?service:*`.

A schema is an expression just like Irn. The schema above accept any irn that
start with `irn` followed by a string matched to an organization, then by string
matched to a country then by a service and finally by an optional part that is
any correctly formed irn.

After creating a new schema

```ruby
schema = IfgIrn::Schema.new('irn:?org:?country:?service:*')
```

You can now create valid irn with `Schema#build` method, it either accept an irn
string or a hash of schema parameters.

Create a new irn with an irn string

```ruby
irn = schema.build('irn:acme:france:accounting:product:1234')
```

Create a new irn with schema parameters

```ruby
irn = schema.build(org: 'acme', country: 'france', service: 'accounting', data: 'product:1234')
```

### Working with list of Irn

Sometimes, you may want to check that a given resource is inside a given list of
resources. The `IrnList` class offer convenient method or such task.

Given a list of Irn

```ruby
  acl = IrnList.new([
    'irn:acme:product:1',
    'irn:acme:product:2',
    'irn:acme:product:42',
    'irn:acme:category:*'
  ])
```
`IrnList#member?` will return true if the given irn match with any irn in the irn
list

```ruby
  acl.member?('irn:acme:product:1') # true
  acl.member?('irn:acme:product:*') # false
  acl.member?('irn:acme:category:123') # true
```

`IrnList#match` return a list of irn that match a given pattern. It return a
list of `MatchResult`

```ruby
  result = acl.match('irn:acme:product:*')
  result.map { |r| r.data } # [ '1', '2', '42']
```

## Development


After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ifeelgoods/ifg_irn.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
