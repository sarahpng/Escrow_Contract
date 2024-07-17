// SPDX-License-Identifier: MIT
  
pragma solidity >=0.4.22 <0.9.0;

  // holds funds from sender until certian conditions are met
  // multi release process release on multiple approvals
  // deposit, release, refund funds
  // upgradable proxy contract

contract Escrow {

  struct SellerInfo {
    bool isReleaseApproved;
    uint256 amount;
  }

  address public arbitrator; // address of the proxy contract

  mapping (address => mapping (address => SellerInfo)) private sender;

  constructor(address _arbitrator) {
    arbitrator = _arbitrator;
  }

  function deposit(address _user,address _seller) external payable {
    require(_seller != address(0), "Escrow Contract: Cannot be zero address");
    require(!sender[_user][_seller].isReleaseApproved, "Escrow Contract: Release is approved cannot add funds");
    require(msg.value > 0, "Escrow Contract: Amount cannot be zero");
    sender[_user][_seller].amount += msg.value;
  }
  
  function release(address _user, address _seller) external payable {
    require(sender[_user][_seller].isReleaseApproved, "Escrow Contract: Release is not approved");
    require(sender[_user][_seller].amount > 0, "Escrow Contract: Invalid amount to release");
    (bool success, ) = payable(_seller).call{value: sender[_user][_seller].amount}("");
    require(success, "Escrow Contract: Release failed");
    delete sender[_user][_seller];
  }

  function refundFunds(address _user, address _seller) external payable {
    require(!sender[_user][_seller].isReleaseApproved, "Escrow Contract: Release is approved cannot refund");
    require(sender[_user][_seller].amount > 0, "Escrow Contract: Invalid amount to refund");
    (bool success, ) = payable(_user).call{value: sender[_user][_seller].amount}("");
    require(success, "Escrow Contract: Refund failed");
    delete sender[_user][_seller];
  }

  function releaseApproval(address _user, address _seller, bool _isDone) public {
    require(msg.sender == arbitrator, "Escrow Contract: Only arbitrator can approve the release");
    require(!sender[_user][_seller].isReleaseApproved, "Escrow Contract: Release is already approved");
    require(sender[_user][_seller].amount > 0, "Escrow Contract: Invalid amount for release approval");
    sender[_user][_seller].isReleaseApproved = _isDone;
  }

}
