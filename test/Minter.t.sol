// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';
import '../src/Minter.sol';

contract DepositToken is ERC20 {
  constructor(string memory name_, string memory symbol_, uint supply_) ERC20(name_, symbol_) {
    _mint(msg.sender, supply_);
  }
}

contract MinterTest is Test {
  Minter public minter;
  DepositToken public dt;
  uint constant SUPPLY = 100_000 ether;

  function setUp() public {
    dt = new DepositToken('Deposit Token', 'DT', SUPPLY);
    minter = new Minter('Share Tokens', 'STO', address(dt));
  }

  function testDeployment() public {
    assertTrue(keccak256(abi.encodePacked(minter.name())) == keccak256(abi.encodePacked('Share Tokens')), 'Name Check');
    assertTrue(keccak256(abi.encodePacked(minter.symbol())) == keccak256(abi.encodePacked('STO')), 'Symbol Check');
    assertTrue(dt.totalSupply() == SUPPLY, 'Supply check');
  }

  function testAddInvestor() public {
    address user = address(0x01);
    uint cap = 10_000 ether;
    minter.addInvestor(user, cap);
    _checkInvestor(user, true, cap, 0);
  }

  function testAddInvestorRevert() public {
    address user = address(0x01);
    uint cap = 10_000 ether;
    minter.addInvestor(user, cap);
    vm.expectRevert(bytes('Minter: User already whitelisted'));
    minter.addInvestor(user, cap);
  }

  function _checkInvestor(address _user, bool _whitelist, uint _cap, uint _deposited) internal {
    (bool wl, uint cp, uint dp) = minter.getInvestor(_user);
    assertTrue(_whitelist == wl, 'Whitelist check');
    assertTrue(_cap == cp, 'Cap check');
    assertTrue(_deposited == dp, 'Deposit check');
  }
}
