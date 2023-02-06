// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Script.sol';

contract ScriptCommon is Script {
  function concat(string memory a, string memory b) public pure returns (string memory) {
    return string(abi.encodePacked(a, b));
  }

  function usdcAmount(uint256 amount) public pure returns (uint256) {
    return amount * 1000000;
  }

  function writeAddress(string memory name, address addr) public {
    vm.writeFile(concat('dist/', name), vm.toString(address(addr)));
  }
}
