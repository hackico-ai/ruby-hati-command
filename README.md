# ![Ruby](icon.svg) hati-command

The `hati-command` gem is designed to simplify command execution, emphasizing effective handling of success and failure outcomes. It can be employed as a service object or interactor, fostering clean and organized code for managing complex operations.

- **hati-command** provides a simple and flexible way to handle command execution and result handling.

- **hati-command** offers a `Success` and `Failure` result classes to handle command execution results.

- **hati-command** It provides a `Result` object to access the result value, success, and failure, along with options to attach custom messages and metadata for better context.

## Features

- **Command Execution**: Execute commands seamlessly, allowing for optional parameters.
- **Success Handling**: Provides success responses with transformed messages and additional metadata.
- **Failure Handling**: Handles failures gracefully, returning informative messages and context.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
  - [Handling Success](#handling-success)
  - [Handling Failure](#handling-failure)
  - [Transactional Behavior](#transactional-behavior-fail-fast-with-failure)
- [Advanced Usage](#advanced-usage)
  - [Result Customization](#result-customization)
    - [meta](#meta)
    - [error](#error)
    - [trace](#trace)
  - [Command Configurations](#command-configurations)
    - [failure](#failure)
    - [fail_fast](#fail_fast)
    - [unexpected_err](#unexpected_err)
    - [result_inference](#result_inference)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add hati-command
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install hati-command
```

## Basic Usage

To use the `hati-command` gem, you can create a command class that includes the `HatiCommand::Cmd` module. Here’s a simple example:

```ruby
require 'hati_command'

class GreetingCommand
  include HatiCommand::Cmd

  def call(greeting = nil)
    message = build_greeting(greeting)
    return message if message.failure?

    process_message(message)
  end

  def build_greeting(greeting)
    greeting ? Success(greeting) : Failure("No greeting provided")
  end

  def process_message(message)
    message.success? ? Success(message.upcase) : Failure("No message provided")
  end
end
```

### Handling `Success`

```ruby
result = GreetingCommand.call("Hello, World!")

puts result.success? # Outputs: true
puts result.failure? # Outputs: false

puts result.success  # Outputs: "HELLO, WORLD!"
puts result.failure  # Outputs: nil

puts result.value    # Outputs: "HELLO, WORLD!"
puts result.result   # Outputs: HatiCommand::Success

```

### Handling `Failure`

```ruby
result = GreetingCommand.call

puts result.failure? # Outputs: true
puts result.success? # Outputs: false

puts result.failure  # Outputs: "No message provided"
puts result.success  # Outputs: nil

puts result.value    # Outputs: "No message provided"
puts result.result   # Outputs: HatiCommand::Failure
```

### Transactional Behavior: Fail Fast with `Failure!`

```ruby
class GreetingCommand
  include HatiCommand::Cmd

  # NOTE: Will catch unexpected and wrap to HatiCommand::Failure object
  #       Requires true || ErrorObject
  command do
    unexpected_err true
  end

  def call(params)
    message = process_message(params[:message])
    msg = normalize_message(message, params[:recipients])

    Success(msg)
  end

  # NOTE: No message passed - auto break an execution
  def process_message(message)
    message ? message.upcase : Failure!("No message provided")
  end

  def normalize_message(message, recipients)
    Failure!("No recipients provided") if recipients.empty?

    recipients.map { |recipient| "#{recipient}: #{message}" }
  end
end
```

```ruby
# NOTE: No message passed - command exited
#       Returns Result (Failure) object
result = GreetingCommand.call

puts result.failure? # Outputs: true
puts result.failure  # Outputs: "No message provided"
puts result.value    # Outputs: "No message provided"
```

```ruby

result = GreetingCommand.call(params.merge(message: "Hello!"))

puts result.failure? # Outputs: true
puts result.failure  # Outputs: "No recipients provided"
puts result.value    # Outputs: "No recipients provided"
```

```ruby
result = GreetingCommand.call(params.merge(recipients: ["Alice", "Bob"]))

puts result.failure? # Outputs: false
puts result.success  # Outputs: true
puts result.value    # Outputs: ["Alice: Hello!", "Bob: Hello!"]
```

## Advanced Usage

Configurations and customization allow users to tailor the command to meet their specific needs and preferences

### `Result` Customization

Here are some advanced examples of result customization. Available options are

- `meta` - Hash to attach custom metadata
- `err` - Message or Error access via `error` method
- `trace` - By design `Failure!` and `unexpected_err` error's stack top entry

### .meta

```ruby
class GreetingCommand
  include HatiCommand::Cmd
  # ...
  def process_message(message)
    Success(message.upcase, meta: { lang: :eng, length: message.length })
  end
  # ...
end
```

```ruby
result = GreetingCommand.("Hello, Advanced World!")
puts result.value         # Outputs: "HELLO, ADVANCED WORLD!"

puts result.meta[:lang]   # Outputs: :eng
puts result.meta[:length] # Outputs: 22
puts result.meta          # Outputs: {:lang=>:eng, :length=>22}
```

### .error

##### set via `err` access via `error` method. Availiable as param for `#Success` as well (ex. partial success)

```ruby
class GreetingCommand
  include HatiCommand::Cmd
  # ...
  def process_message(message)
    Failure(message, err: "No message provided")
  end
end
```

```ruby
result = GreetingCommand.call
puts result.value   # Outputs: nil
puts result.error   # Outputs: "No message provided"
puts result.trace   # Outputs:
```

### .trace

##### Available as accessor on `Result` object

```ruby
1| class DoomedCommand
2|   include HatiCommand::Cmd
3|
4|   def call
5|     Failure!
6|   end
7|   # ...
8| end
```

```ruby
result = GreetingCommand.call
puts result.failure? # Outputs: true
puts result.trace    # Outputs: path/to/cmds/doomed_command.rb:5:in `call'
```

### Command `Configurations`

Provides options for default failure message or errors. Available configs are:

- `failure` - Message or Error
- `fail_fast` - Message or Error
- `unexpected_err` - Bool(true) or Message or Error

### failure

```ruby
1 | class DoomedCommand
2 |   include HatiCommand::Cmd
3 |
4 |   command do
5 |     failure "Default Error"
6 |   end
7 |
8 |   def call(error = nil, fail_fast: false)
9 |     Failure! if fail_fast
10|
11|     return Failure("Foo") unless option
12|
13|     Failure(error, err: "Insufficient funds")
14|   end
15|   # ...
16| end
```

```ruby
result = DoomedCommand.call(fail_fast: true)
# NOTE: not configured fail fast uses default error
puts result.failure # Outputs: nil
puts result.error   # Outputs: "Default Error"
puts result.trace   # Outputs: path/to/cmds/doomed_command.rb:5:in `call'


result = DoomedCommand.call
puts result.failure # Outputs: "Foo"
puts result.error   # Outputs: "Default Error"

result = DoomedCommand.call('Buzz')
puts result.failure # Outputs: "Buzz"
puts result.error   # Outputs: "Insufficient funds"
```

### fail_fast

```ruby
1 | class DoomedCommand
2 |   include HatiCommand::Cmd
3 |
4 |   command do
5 |     fail_fast "Default Fail Fast Error"
6 |   end
7 |
8 |   def call
9 |     Failure!
10|   end
11|   # ...
12| end
```

```ruby
result = DoomedCommand.call
puts result.failure # Outputs: nil
puts result.error   # Outputs: "Default Fail Fast Error"
puts result.trace   # Outputs: path/to/cmds/doomed_command.rb:9:in `call'
```

### unexpected_err

```ruby
1 | class GreetingCommand
2 |   include HatiCommand::Cmd
3 |
4 |   command do
5 |     unexpected_err true
5 |   end
6 |
7 |   def call
8 |     1 + "2"
9 |   end
10|   # ...
11| end
```

```ruby
result = GreetingCommand.call
puts result.failure # Outputs: nil
puts result.error   # Outputs: TypeError: no implicit conversion of Integer into String
puts result.trace   # Outputs: path/to/cmds/greeting_command.rb:9:in `call'
```

### unexpected_err (wrapped)

```ruby
1 | class GreetingCommand
2 |   include HatiCommand::Cmd
3 |
4 |   class GreetingError < StandardError; end
5 |
6 |   command do
7 |     unexpected_err GreetingError
8 |   end
9 |
10|   def call
11|     1 + "2"
12|   end
13|   # ...
14| end
```

```ruby
result = GreetingCommand.call
# NOTE: Original error becomes value (failure)
puts result.failure # Outputs: TypeError: no implicit conversion of Integer into String

puts result.error   # Outputs: GreetingError
puts result.trace   # Outputs: path/to/cmds/greeting_command.rb:12:in `call'
```

### result_inference

```ruby
1 | class GreetingCommand
2 |   include HatiCommand::Cmd
3 |
4 |   command do
5 |     result_inference true # Implicitly wraps non-Result as Success
5 |   end
6 |
7 |   def call
8 |     42
9 |   end
10|   # ...
11| end
```

```ruby
result = GreetingCommand.call
puts result.success  # Outputs: 42
puts result.failure? # Outputs: false
```

## Authors

- [Yuri Gi](https://github.com/yurigitsu)
- [Marie Giy](https://github.com/mariegiy)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hackico-ai/hati-command. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hackico-ai/hati-command/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HatCommand project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hackico-ai/hati-command/blob/main/CODE_OF_CONDUCT.md).
