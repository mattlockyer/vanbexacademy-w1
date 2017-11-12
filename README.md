

# Bike Share

Bike share is a collection of smart contracts to facilitate the creation of a bicycle sharing dapp.

## Running Tests

Please install and run testrpc.

`npm install ethereumjs-testrpc`

In another terminal run `truffle test` to run the tests.

## Test Coverage

Tests should cover all interactions with the bike share network.

## TO DO (make issues)

1. Implement restrictions, i.e. use ownable for functions in place of a consensus system
2. Do not allow renters to rent the same bike
3. Do not allow renters to ride beyond their credits
4. Likely many more restrictions to be found