# CrosschainERC20

`CrosschainERC20` is a token implementation that combines [`ERC-7281`](https://ethereum-magicians.org/t/erc-7281-sovereign-bridged-tokens/14979) and [`ERC-7802`](https://ethereum-magicians.org/t/erc-7802-crosschain-token-interface/21508) functionality. This allows tokens to be immediately usable with existing bridge infrastructure while being compatible with the Superchain interop cluster.

### Contracts

_CrosschainERC20_: A token implementation that extends XERC20 and implements the ERC7802 interface. This allows it to interact with both ERC-7281-compatible bridges and ERC7802-compatible bridges, providing unified cross-chain fungibility across any bridge type.

_ERC7802Adapter_: An adapter contract that provides ERC7802 functionality for existing xERC20 tokens. It acts as an intermediary layer allowing bridges that implement ERC7802 to interact with xERC20 tokens that don't natively support this interface.

_CrosschainERC20Factory_: The factory is used as a helper to deploy CrosschainERC20 tokens and related contracts. It allows the user to deploy the CrosschainERC20, XERC20Lockbox (with different setup to mint CrosschainERC20 tokens), and ERC7802Adapter in a convenient way while keeping deterministic addresses across chains.

### Flows

#### Deploy and Setup CrosschainERC20

```mermaid
sequenceDiagram
    actor D as Deployer
    participant F as Factory
    participant C as CrosschainERC20
    actor O as Owner

    D ->> F: deployCrosschainERC20(... owner)
    F ->> C: constructor(... owner)
    O ->> C: setLimits(7281 bridge ...)
    O ->> C: setLimits(7802 bridge ...)
```

#### CrosschainERC20 Usage

```mermaid
sequenceDiagram
    actor A as Alice
    participant B1 as ERC7281 Bridge
    participant B2 as ERC7802 Bridge
    participant C as CrosschainERC20

    A ->> B1: bridgeToken()
    B1 ->> C: burn()
    A ->> B2: bridgeToken()
    B2 ->> C: crosschainBurn()
```

```mermaid
sequenceDiagram
    actor A as Alice
    participant B1 as ERC7281 Bridge
    participant B2 as ERC7802 Bridge
    participant C as CrosschainERC20

    A ->> B1: receiveToken()
    B1 ->> C: mint()
    A ->> B2: receiveToken()
    B2 ->> C: crosschainMint()
```

#### Deploy and setup CrosschainERC20Lockbox

```mermaid
sequenceDiagram
    actor D as Deployer
    participant F as Factory
    participant C as CrosschainERC20
    participant L as Lockbox

    D ->> F: deployCrosschainERC20WithLockbox(... owner)
    F ->> C: constructor(... owner)
    F ->> L: constructor(crosschainERC20, ERC20)
    F ->> C: setLockbox(lockbox)
    F ->> C: transferOwnership(owner)
```

#### Lockbox Usage

```mermaid
sequenceDiagram
    actor A as Alice
    participant L as Lockbox
    participant E as ERC20
    participant C as CrosschainERC20

    A ->> L: deposit()
    L ->> E: transferFrom(Alice, Lockbox)
    L ->> C: mint(Alice)
```

```mermaid
sequenceDiagram
    actor A as Alice
    participant L as Lockbox
    participant E as ERC20
    participant C as CrosschainERC20

    A ->> L: withdraw()
    L ->> E: transfer(Alice, amount)
    L ->> C: burn(Alice)
```

#### Deploy and setup ERC7802Adapter

```mermaid
sequenceDiagram
    actor D as Deployer
    participant F as Factory
    participant A as ERC7802Adapter

    D ->> F: deployERC7802Adapter(xerc20, bridge)
    F ->> A: constructor(xerc20, bridge)
```

```mermaid
sequenceDiagram
    actor O as Owner
    participant X as XERC20

    O ->> X: setLimits(adapter)
```

#### Adapter Usage

```mermaid
sequenceDiagram
    actor A as Alice
    participant B as ERC7802 Bridge
    participant AD as ERC7802Adapter
    participant C as XERC20

    A ->> AD: bridgeToken()
    B ->> AD: crosschainBurn()
    AD ->> C: burn()
```

```mermaid
sequenceDiagram
    actor A as Alice
    participant B as ERC7802 Bridge
    participant AD as ERC7802Adapter
    participant C as XERC20

    A ->> B: receiveToken()
    B ->> AD: crosschainMint()
    AD ->> C: mint()
```

## Setup

1. Install Foundry by following the instructions from [their repository](https://github.com/foundry-rs/foundry#installation).
2. Copy the `.env.example` file to `.env` and fill in the variables
3. Install the dependencies by running : `yarn install && forge install`

## Build

The default way to build the code is suboptimal but fast, you can run it via:

```bash
yarn build
```

In order to build a more optimized code ([via IR](https://docs.soliditylang.org/en/v0.8.15/ir-breaking-changes.html#solidity-ir-based-codegen-changes)), run:

```bash
yarn build:optimized
```

## Running tests

Unit tests should be isolated from any externalities, while E2E usually run in a fork of the blockchain.

```bash
yarn test
```

## Licensing

The primary license for xERC20 is MIT, see [LICENSE](./LICENSE).
