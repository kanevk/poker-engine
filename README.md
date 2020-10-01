# Poker Engine

Horizontally scalable, immutable, and thread-safe poker library written in Ruby,
utilizing the [Redux design pattern](https://redux.js.org/recipes/structuring-reducers/structuring-reducers#structuring-reducers)
and [Persistent data structures](https://en.wikipedia.org/wiki/Persistent_data_structure).

## Example

There is a simple console interface that you can run `./examples/simple-gameplay.rb` and play against yourself!

Valid moves:
- check
- fold
- call
- raise [bet amount], example: __raise 100__

## Documentation

You can think about the `PokerEngine::Game` like for a state machine. You can initiate it with `.start` and you can transition from one state in another with `.next`.

For more info check you can check the [console example](./examples/simple-gameplay.rb) or the [integration spec](./spec/integration_spec.rb).

## Setup

1. Make sure you have Ruby and bundler installed

2. Clone the repo

```shell
git clone git@github.com:kanevk/poker-engine.git
```

3. Install the dependencies
```shell
bundle
```

4. Run tests

```shell
bundle exec rspec -fd
```
