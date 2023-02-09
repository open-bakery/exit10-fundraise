// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Script.sol';
import '../src/Minter.sol';

contract DeployMainnetScript is Script {
  Minter public minter;
  IMinter.DeployParams params;

  function setUp() public {
    params = IMinter.DeployParams({
      name: 'Share Token',
      symbol: vm.envString('SYMBOL'),
      depositToken: vm.envAddress('DEPOSIT_TOKEN'),
      minInvestmentAmount: vm.envUint('MIN_INVESTMENT_AMOUNT')
    });
  }

  function run() public {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');

    vm.startBroadcast(deployerPrivateKey);

    minter = new Minter(params);

    vm.stopBroadcast();
  }
}
