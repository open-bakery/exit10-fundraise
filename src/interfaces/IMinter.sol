// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IMinter is IERC20 {
  struct DeploymentArgs {
    string name;
    string symbol;
    uint depositToken;
    uint price;
  }
}
