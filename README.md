# Auction Contract

This repository contains a Solidity smart contract for an auction. The contract allows a seller to auction items with customizable parameters such as duration, number of winners, and bid increment.

## Features

- **Place Bids**: Bidders can place bids during the active auction period. Bids must be higher than the current highest bid plus a specified increment.

- **End Auction**: The seller can end the auction before its expiry. The auction ends by selecting the top bidders as winners.

- **Increase Duration**: The seller can increase the duration of the auction before its expiry.

- **Withdraw Funds**: The seller can withdraw the funds from the auction contract after it ends.

## Events

- **BidPlaced**: Emitted when a bid is placed. Includes the address of the bidder and the amount of the bid.

- **AuctionEnded**: Emitted when the auction ends. Includes the addresses of the winners and the amounts of the winning bids.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Auction.s.sol:AuctionScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
