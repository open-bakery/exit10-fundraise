// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../src/Minter.sol';
import '../src/interfaces/IMinter.sol';
import '../src/mock/USDC.sol';

contract MinterTest is Test {
  Minter public minter;
  address public depositToken;
  uint constant SUPPLY = 100_000 ether;

  IMinter.DeployParams params;

  function setUp() public {
    depositToken = address(new USDC(SUPPLY));
    params = IMinter.DeployParams({
      name: 'Share Tokens',
      symbol: 'STO',
      depositToken: depositToken,
      minInvestmentAmount: _tokenAmount(1_000, depositToken)
    });
    minter = new Minter(params);
  }

  function testDeployment() public {
    assertTrue(keccak256(abi.encodePacked(minter.name())) == keccak256(abi.encodePacked('Share Tokens')), 'Name Check');
    assertTrue(keccak256(abi.encodePacked(minter.symbol())) == keccak256(abi.encodePacked('STO')), 'Symbol Check');
    assertTrue(ERC20(depositToken).totalSupply() == SUPPLY, 'Supply check');
  }

  function testWhitelist() public {
    address user = address(0x01);
    uint cap = _tokenAmount(10_000, depositToken);
    minter.whitelistOrEditCap(user, cap);
    _checkInvestor(user, cap, 0);
  }

  function testAddInvestorRevert() public {
    address user = address(0x01);
    uint cap = _tokenAmount(10_000, depositToken);
    minter.whitelistOrEditCap(user, cap);
    vm.expectRevert(bytes('Minter: Cap already set'));
    minter.whitelistOrEditCap(user, cap);
  }

  function _checkInvestor(address _user, uint _cap, uint _deposited) internal {
    (uint cp, uint dp) = minter.investor(_user);
    assertTrue(_cap == cp, 'Cap check');
    assertTrue(_deposited == dp, 'Deposit check');
  }

  function _tokenAmount(uint _amountWithNoDecimals, address _token) internal view returns (uint) {
    return _amountWithNoDecimals * 10 * ERC20(_token).decimals();
  }
}
