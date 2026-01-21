# ![Ruby](icon.svg) hati-command

The `hati-command` gem provides a lightweight framework for structuring logic as discrete, callable actions — ideal for agentic AI systems that require modular execution and explicit outcome handling.

- **hati-command** lets you define commands as service objects or interactors, ready for orchestration by AI agents.
- **hati-command** returns standardized `Success` and `Failure` results, making it easy to reason about next steps in autonomous workflows.
- **hati-command** provides built-in error tracing and metadata propagation, enabling reliable debugging, observability, and auditability across execution chains.
- **hati-command** supports integrated transaction handling, allowing commands to execute safely within database or domain-level transactional boundaries.

## Features

- **Command Execution**: Encapsulate atomic operations with clear input/output boundaries for agent use.
- **Structured Results**: Use `Result` objects with status, value, and metadata for deterministic planning.

- **Deterministic command execution**: Clear input → execution → outcome boundaries with no hidden side effects.
- **Failure as structured data**: Errors are returned as explicit results, not raised implicitly.
- **Framework-agnostic service objects**: Works with plain Ruby or Rails without architectural coupling.
- **Execution transparency**: Decision points and failure paths are visible and inspectable.
- **Reliable foundation for automation and AI tooling**: Suitable for orchestration layers where correctness and traceability matter.

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
  - [Native DB Transaction](#native-db-active-record-transaction)
  - [Command Configurations](#command-configurations)
    - [result_inference](#result_inference)
    - [call_as](#call_as)
    - [failure](#failure)
    - [fail_fast](#fail_fast)
    - [unexpected_err](#unexpected_err)
    - [ar_transaction](#ar_transaction)

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

To use the `hati-command` gem, you can create a command class that includes the `HatiCommand::Cmd` module.

Note: No need to nest object APIs under `private` as popular template for `Servie Object` designs

    only main caller method is public by design

#### Example

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

### Command `API`

```ruby
result = GreetingCommand.call("Hello, World!") # Outputs: Result
result = GreetingCommand.new                   # Outputs: private method `new' called
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

- `result_inference`(Bool(true)) => implicit Result wrapper
- `call_as`(Symbol[:call]) => Main call method name
- `failure`(String | ErrorClass) => Message or Error
- `fail_fast`(String || ErrorClass) => Message or Error
- `unexpected_err`(Bool[true]) => Message or Error

#### Native DB Active Record Transaction:

- `ar_transaction`(Array[Symbol], returnable: Bool[true]) => methods to wrap in Transaction, requires 'activerecord'

```ruby
class AppService
  include HatiCommand::Cmd

  command do
    result_inference true
    call_as :perform
    failure "Default Error"
    fail_fast "Default Fail Fast Error"
    unexpected_err BaseServiceError
  end

  # ...
end

class PaymentService < AppService
  command do
    ar_transaction :perform
    unexpected_err PaymentServiceTechnicalError
  end

  def perform(params)
    account = Account.lock.find(user_id)
    Failure("User account is inactive") unless user.active?

    CreditTransaction.create!(user_id: user.id, amount: amount)
    AuditLog.create!(action: 'add_funds', account: account)

    Success('Funds has been add to account')
  end

  # ...
end

```

### result_inference

```ruby
class GreetingCommand
  include HatiCommand::Cmd

  command do
    result_inference true # Implicitly wraps non-Result as Success
  end

  def call
    42
  end
  # ...
end
```

```ruby
result = GreetingCommand.call
puts result.success  # Outputs: 42
puts result.failure? # Outputs: false
```

### call_as

```ruby
class GreetingCommand
  include HatiCommand::Cmd

  command do
    call_as :execute # E.q. :perform, :run, etc.
  end

  def execute
    Success(42)
  end
  # ...
end
```

```ruby
result = GreetingCommand.execute
puts result.success  # Outputs: 42
puts result.failure? # Outputs: false
```

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

NOTE: not configured fail fast uses default error

```ruby
result = DoomedCommand.call(fail_fast: true)

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

NOTE: Original error becomes value (failure)

```ruby
result = GreetingCommand.call

puts result.failure # Outputs: TypeError: no implicit conversion of Integer into String
puts result.error   # Outputs: GreetingError
puts result.trace   # Outputs: path/to/cmds/greeting_command.rb:12:in `call'
```

### ar_transaction

Wraps listed methods in Transaction with blocking non-Result returns.
At this dev stage relies on 'activerecord'

- NOTE: considering extensicve expirience of usage, we recomend to use some naming convention
  across codebase for such methods, to keep healthy Elegance-to-Explicitness ratio

  #### E.g. suffixes: \_flow, \_transaction, \_task, etc.

- NOTE: `Failure()` works as transaction break, returns only from called method's as Result (Failure) object

- NOTE: `Failure!()` works on Service level same fail_fast immediately halts execution, return from

- NOTE: Unlike `ActiveRecord::Transaction` Implicit non-Result returns will trigger `TransactionError`,
  blocking partial commit state unless:

```ruby
  ar_transaction :transactional_method_name, returnable: false # Defaults to true
```

### Pseudo-Example:

```ruby
  class PaymentService < AppService
    command do
      ar_transaction :add_funds_transaction
      unexpected_err PaymentServiceTechnicalError
    end

    def call(params)
      amount = currency_exchange(params[:amount])
      debit_transaction = add_funds_transaction(amount)

      return debit_transaction if debit_transaction.success?

      Failure(debit_transaction, err: 'Unable to add funds')
    end

    def currency_exchange
      # ...
    end

    # Whole method evaluates in ActiveRecord::Transaction block
    def add_funds_transaction(amount)
      account = Account.lock.find(user_id)
      Failure("User account is inactive") unless user.active?

      # Fires TransactionError, unless :returnable configuration is disabled
      return 'I am an Error'

      user.balance += amount
      user.save
      Failure('Account debit issue') if user.errors

      CreditTransaction.create!(user_id: user.id, amount: amount)
      AuditLog.create!(action: 'add_funds', account: account)

      # NOTE: result inference won't work, use only Result objects
      Success('Great Succeess')
    end

  # ...
  end
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
