// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract USDC is ERC20 {
  constructor(uint supply_) ERC20('USD Coin', 'USDC') {
    _mint(msg.sender, supply_);
  }

  function decimals() public view virtual override returns (uint8) {
    return 6;
  }
}
