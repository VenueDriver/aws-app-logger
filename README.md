# Aws::App::Logger

This Ruby gem will emit log messages the way you normally do from Ruby,
but leverage the power of AWS CloudWatch, with metrics, alerts, Log Insights,
visualization, and more.

You might have a lot of Ruby code that's already full of log statements that
use the standard Logger class, like this:

    $logger.info  "Starting to process order: #{@order.id}"
    $logger.debug "Order: #{@order.inspect}"
    ...
    $logger.info  "Order final: #{@order.id}"

If you're using AWS Lambda to run your code, then you'll be able to see your
logs and search then in AWS CloudWatch:

    2022-10-12T16:20:45.891-05:00	DEBUG: Starting to process order: 1234
    2022-10-12T16:20:45.891-05:00	DEBUG: Order: {:id=>"1234", :total=>"4592", :subtotal=>"..." ... }
    2022-10-12T16:20:47.369-05:00	DEBUG: Order: {:id=>"1234", :total=>"4592", :subtotal=>"..." ... }

But, you could get more out of CloudWatch.  You could log your `@order` object
as machine-readable data that you could
[query](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)
with [CloudWatch Log Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html).

When you have an operational problem and a message goes into a dead-letter queue,
your operators will need a quick way to query your logs for other messages
related to the message.  In this example, where the messages relate to an
application that 'processes orders' of some kind, you might want to quickly
find the log entries related to that order so that you can trace its lifecycle
and decide how to handle the message.

With this gem, you can log your existing messages just like you did before.
But instead of passing just a message when you emit a log statement, you can
provide structured data.

So, this:

    $logger.info "Starting to process order: #{@order.id}"

...becomes:

    $logger.info Starting to process order.', @order.id

And instead of this in your logs:

    2022-10-12T16:20:45.891-05:00	DEBUG: Starting to process order: 1234

...you get this:

    2022-10-12T16:20:45.891-05:00	DEBUG: Starting to process order.
      {"message":"Starting to process order.", "id":"1234","total":"4592","subtotal":"..."}

Now, you can use AWS Log Insights to locate every `message` related to any
specific order `id`, because both of those things are machine-readable and
indexed.  You can also do queries for lifecycle events related to orders
where the total was greater than X, or where the subtotal was exactly Y,
or things that make sense within your application.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add aws-app-logger

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install aws-app-logger

## Usage

If you have existing log statements in your code that assume that there is a
global `$logger` for you to use for logging, then you can override the default
logger with:

    require 'aws-app-logger'
    $logger = Aws::App::Logger.new

Coming soon:

    $logger = Aws::App::Logger.new(
      application: 'Your App Name Here',
      environment: 'staging'
    )
    ...
    2022-10-12T16:20:45.891-05:00	DEBUG: Starting to process order.
      {"message":"Starting to process order.", "application":"Your App Name Here", "environment":"staging", "id":"1234","total":"4592","subtotal":"..."}


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aws-app-logger.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
