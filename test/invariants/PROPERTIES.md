# CrosschainERC20 Advanced Testing Campaign

This campaign aims to develop a testing suite that fuzzes over the interop invariants introduced or modified by the Wonderland team. The main focus is on testing stateful properties and dismissing unit tests that are already covered by the existing test suite.

## Milestones

- CrosschainERC20: Mainly composed of invariants related to `CrosschainERC20`, focus on total supply, minting and burning.
- Factory: Mainly composed of invariants related to `CrosschainERC20Factory`, focus on the deployments.
- Adapter: Mainly composed of invariants related to `ERC7802Adapter`, focus on the `deposit` and `withdraw` functions.

# Properties

**Legend:**

- `[ ]`: property not yet tested
- `[X]`: tested/proven property
- `[~]`: partially tested/proven property
- `:(`: property won't be tested due to some limitation

| Id  | Milestone       | Description                                                                                                                               | Tested |
| --- | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------ |
|     | Factory         | Is not possible to deploy a CrosschainERC20 with the same name, symbol and decimals as an already deployed one using the same msg.sender. | [X]    |
|     | CrosschainERC20 | The total supply of the CrosschainERC20 is the same as the ERC20 locked in the lockbox.                                                   | [ ]    |
