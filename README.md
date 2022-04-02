# FriendsOnChain Contracts

This is the contact repository for Bunches' Friends on Chain project. It's an ERC1155 contract with some specificities like max 7 users, etc.

## Getting Started

`yarn install`

To build:

`yarn build`

To run dev watch mode:

`yarn dev`

## Working with the contract:

After the contract is deployed, to create a group a minter will mint() with seven (7) addreses:

```
contract.createGroup([
  "0x1...",
  "0x2...",
  "0x3...",
  "0x4...",
  "0x5...",
  "0x6...",
  "0x7...",
])
```

This will mint a new token with the 7 addresses with TokenID 1. TokenID will automatically be incremented.

To check if an address is a member of the group:

```
contract.isMember("0x1...", "1") // accepts (address, tokenId)
```
