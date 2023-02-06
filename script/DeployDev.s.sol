// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import './ScriptCommon.sol';
import '../src/Minter.sol';
import '../src/mock/USDC.sol';

contract DeployDev is ScriptCommon {
  Minter public minter;
  USDC public usdc;

  function run() public {
    uint256 deployerKey = vm.envUint('PRIVATE_KEY');
    uint256 aliceKey = vm.envUint('ALICE_KEY');
    uint256 bobKey = vm.envUint('BOB_KEY');
    uint256 charlieKey = vm.envUint('CHARLIE_KEY');
    uint256 daveKey = vm.envUint('DAVE_KEY');
    address aliceAddress = vm.envAddress('ALICE_ADDRESS');
    address bobAddress = vm.envAddress('BOB_ADDRESS');
    address charlieAddress = vm.envAddress('CHARLIE_ADDRESS');
    address daveAddress = vm.envAddress('DAVE_ADDRESS');

    // initial contributions:
    // - alice: not whitelisted
    // - bob: whitelisted, not contributed
    // - charlie: contributed 10k
    // - dave: contributed 20k

    // deploy
    vm.startBroadcast(deployerKey);
    usdc = new USDC(usdcAmount(1_000_000));
    usdc.transfer(aliceAddress, usdcAmount(100_000));
    usdc.transfer(bobAddress, usdcAmount(100_000));
    usdc.transfer(charlieAddress, usdcAmount(100_000));
    usdc.transfer(daveAddress, usdcAmount(100_000));
    IMinter.DeployParams memory params = IMinter.DeployParams({
      name: vm.envString('NAME'),
      symbol: vm.envString('SYMBOL'),
      depositToken: address(usdc),
      minInvestmentAmount: vm.envUint('MIN_INVESTMENT_AMOUNT')
    });
    minter = new Minter(params);
    writeAddress('usdc', address(usdc));
    writeAddress('minter', address(minter));
    minter.whitelistOrEditCap(bobAddress, usdcAmount(10_000));
    minter.whitelistOrEditCap(charlieAddress, usdcAmount(10_000));
    minter.whitelistOrEditCap(daveAddress, usdcAmount(20_000));
    vm.stopBroadcast();

    vm.startBroadcast(charlieKey);
    usdc.approve(address(minter), type(uint256).max);
    minter.deposit(usdcAmount(10_000));
    vm.stopBroadcast();

    vm.startBroadcast(daveKey);
    usdc.approve(address(minter), type(uint256).max);
    minter.deposit(usdcAmount(20_000));
    vm.stopBroadcast();
  }
}
