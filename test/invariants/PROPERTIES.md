# CrosschainERC20 Advanced Testing Campaign

This testing campaign aims to verify the correctness and security of the CrosschainERC20 system through invariant testing. The campaign focuses on three main components:


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

| Id  | Milestone       | Description                                                                                                                                                           | Tested |
| --- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 1   | Factory         | The same msg.sender MUST NOT be able to deploy a CrosschainERC20 on the same address as one that he already deployed one using different params                          | [X]    |
| 2   | Factory         | Different msg.sender's MUST NOT be able to deploy a CrosschainERC20 on the same address on different chains                         | [X]    |
| 3   | Factory         | A CrosschainERC20 MUST NOT be able to be deployed on the same address on different chains using different params                         | [X]    |
| 3   | CrosschainERC20 | The total supply of the CrosschainERC20 equals the ERC20 locked in the lockbox (without considering transfers to its own address) +/- bridged CrosschainERC20 tokens. | [X]    |
| 4   | CrosschainERC20 | The bridge limits cannot be set to a value greater than the max allowed.                                                                                              | [X]    |
| 5   | CrosschainERC20 | Current limit can not be reset by setting new limits.                                                                                                                 | [X]    |
