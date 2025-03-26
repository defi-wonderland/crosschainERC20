# CrosschainERC20 Advanced Testing Campaign

This testing campaign aims to verify the correctness and security of the CrosschainERC20 system through invariant testing. The campaign focuses on three main components:

## Milestones

1. CrosschainERC20 Token Contract

- Verifying total supply invariants
- Testing minting/burning functionality
- Ensuring proper access controls

2. CrosschainERC20Factory Contract

- Testing deployment logic and uniqueness constraints
- Validating initialization parameters
- Checking CREATE3 deterministic deployment

3. ERC7802Adapter Contract

- Testing bridge integration
- Verifying adapter minting/burning permissions

# Properties

**Legend:**

- `[ ]`: property not yet tested
- `[X]`: tested/proven property
- `[~]`: partially tested/proven property
- `:(`: property won't be tested due to some limitation

| Id  | Milestone       | Description                                                                                                                               | Tested |
| --- | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 1   | Factory         | Is not possible to deploy a CrosschainERC20 with the same name, symbol and decimals as an already deployed one using the same msg.sender. | [X]    |
| 2   | CrosschainERC20 | The total supply of the CrosschainERC20 is the same as the ERC20 locked in the lockbox.                                                   | [ ]    |
