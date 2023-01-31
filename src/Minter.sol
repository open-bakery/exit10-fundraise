// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';

import './interfaces/IMinter.sol';

import 'forge-std/Test.sol';

contract Minter is IMinter, ERC20, Ownable {
  using SafeERC20 for ERC20;
  using Math for uint;

  struct Investor {
    uint cap;
    uint deposited;
  }

  address public immutable DEPOSIT_TOKEN;
  uint public immutable MIN_INVESTMENT_AMOUNT;
  uint public constant EARLY_BACKERS_SUPPLY = 150_000 ether;
  uint public constant TEAM_SUPPLY = 150_000 ether;
  uint public constant SUPPLY_CAP = EARLY_BACKERS_SUPPLY + TEAM_SUPPLY;

  bool public isActive = true;

  mapping(address => Investor) public investor;

  constructor(DeployParams memory params) ERC20(params.name, params.symbol) {
    DEPOSIT_TOKEN = params.depositToken;
    MIN_INVESTMENT_AMOUNT = params.minInvestmentAmount;
    _mint(msg.sender, TEAM_SUPPLY);
  }

  function whitelistOrEditCap(address user, uint cap) external onlyOwner {
    _requireMinimumInvestmentAmount(cap);

    Investor storage inv = investor[user];
    require(inv.deposited <= cap, 'Minter: Cap must be higher than deposited amount');
    require(inv.cap != cap, 'Minter: Cap already set');

    inv.cap = cap;
  }

  function closeRaise() external onlyOwner {
    _closeRaise();
    uint remainingToMint = SUPPLY_CAP - totalSupply();
    _mint(msg.sender, remainingToMint);
  }

  function deposit(uint amount) external {
    require(isActive, 'Minter: Raise is no longer active');

    Investor storage inv = investor[msg.sender];
    if (inv.deposited == 0) _requireMinimumInvestmentAmount(amount);

    require(inv.cap != 0, 'Minter: User not whitelisted');
    require(inv.deposited != inv.cap, 'Minter: Investor cap already reached');

    (uint depositAmount, uint mintAmount) = _validateDepositAmount(amount, inv.deposited, inv.cap);

    if (totalSupply() + mintAmount == SUPPLY_CAP) _closeRaise();

    ERC20(DEPOSIT_TOKEN).safeTransferFrom(msg.sender, address(this), depositAmount);
    inv.deposited += depositAmount;

    _mint(msg.sender, mintAmount);
  }

  function pullFunds(address recipient) external onlyOwner {
    ERC20(DEPOSIT_TOKEN).safeTransfer(recipient, ERC20(DEPOSIT_TOKEN).balanceOf(address(this)));
  }

  function _requireMinimumInvestmentAmount(uint _amount) internal view {
    require(_amount >= MIN_INVESTMENT_AMOUNT, 'Minter: Amount must be higher than minimum investment amount');
  }

  function _validateDepositAmount(
    uint _amount,
    uint _prevDeposited,
    uint _cap
  ) internal view returns (uint _validatedDepositAmount, uint _mintAmount) {
    // Checks to see if user has already deposited before and is not overflowing their cap
    // If cap is overflown only deposit up to the cap.
    _validatedDepositAmount = _validateMaximumAllowed(_amount, _prevDeposited, _cap);

    // Checks if user can mint all the tokens from the depositAmount without going over maximum supply
    uint cacheAmountToMint = (_validatedDepositAmount * 10 ** decimals()) / 10 ** ERC20(DEPOSIT_TOKEN).decimals();
    _mintAmount = _validateMaximumAllowed(cacheAmountToMint, totalSupply(), SUPPLY_CAP);

    // If user has gone over the maxSupply, recalculate the depositAmount
    _validatedDepositAmount = (cacheAmountToMint != _mintAmount)
      ? (_mintAmount * 10 ** ERC20(DEPOSIT_TOKEN).decimals()) / 10 ** decimals()
      : _validatedDepositAmount;
  }

  function _validateMaximumAllowed(
    uint _inputAmount,
    uint _currentAmount,
    uint _maximumAmount
  ) internal pure returns (uint _maximumAllowed) {
    _maximumAllowed = _inputAmount + _currentAmount > _maximumAmount
      ? Math.min(_maximumAmount - _currentAmount, _inputAmount)
      : _inputAmount;
  }

  function _closeRaise() internal {
    require(isActive, 'Minter: Raise already closed');
    isActive = false;
  }
}
