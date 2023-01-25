// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';

contract Minter is ERC20, Ownable {
  using SafeERC20 for ERC20;
  using Math for uint;

  struct Investor {
    bool whitelisted;
    uint cap;
    uint deposited;
  }

  address public depositToken;
  uint public price;
  uint public constant SUPPLY_CAP = 100_000 ether;
  uint public constant EARLY_BACKERS_SUPPLY = 50_000 ether;

  mapping(address => Investor) public investor;

  constructor(string memory name_, string memory symbol_, address depositToken_) ERC20(name_, symbol_) {
    depositToken = depositToken_;
  }

  function getInvestor(address user) external view returns (bool whitelist, uint cap, uint deposited) {
    Investor memory inv = investor[user];
    whitelist = inv.whitelisted;
    cap = inv.cap;
    deposited = inv.deposited;
  }

  function addInvestor(address user, uint cap) external onlyOwner {
    Investor memory inv = investor[user];
    require(!inv.whitelisted, 'Minter: User already whitelisted');
    inv.whitelisted = true;
    inv.cap = cap;
    investor[user] = inv;
  }

  function editCap(address user, uint cap) external onlyOwner {
    Investor memory inv = investor[user];
    require(inv.deposited <= cap, 'Minter: Cap must be higher than deposited amount');
    inv.cap = cap;
    investor[user] = inv;
  }

  function removeWhitelistAndRefund(address user) external onlyOwner {
    Investor memory inv = investor[user];
    // inv.whitelisted = false;
    if (inv.deposited != 0) _safeRefund(user);
    delete investor[user];
    //investor[user] = inv;
  }

  function deposit(uint amount) external {
    Investor memory inv = investor[msg.sender];
    require(inv.whitelisted, 'Minter: User not whitelisted');
    require(inv.deposited != inv.cap, 'Minter: Cap already reached');

    uint depositAmount = (amount + inv.deposited) > inv.cap ? Math.min(inv.cap - inv.deposited, amount) : amount;
    require(ERC20(depositToken).balanceOf(msg.sender) >= depositAmount, 'Minter: Not enough to deposit');

    // For tests
    assert(depositAmount + inv.deposited <= inv.cap);

    ERC20(depositToken).safeTransferFrom(msg.sender, address(this), depositAmount);
    inv.deposited += depositAmount;
    investor[msg.sender] = inv;

    _mint(msg.sender, depositAmount);
  }

  function _safeRefund(address _user) internal {
    Investor storage inv = investor[_user];
    uint refundAmount = inv.deposited;
    inv.deposited = 0;
    ERC20(depositToken).safeTransfer(_user, Math.min(refundAmount, ERC20(depositToken).balanceOf(address(this))));
  }
}
