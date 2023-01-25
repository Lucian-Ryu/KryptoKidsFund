// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract KryptoKidsFund is ReentrancyGuard {

    

    address parent;

    event KidAdded(address addr, string firstName, string lastName, uint releaseTime);
    event DepositToKidDone(address addr, uint amount);
    event KidWithdrawalComplete(address addr, uint balance);

    constructor() {
        parent = msg.sender;
    }

    mapping (address => Kid) public kidMapping;

    struct Kid {
        address payable kidAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint balance;
    }

    modifier onlyparent() {
        require(msg.sender == parent, "Only the parent can add kids");
        _;
    }

    function addKid(address payable _kidAddress, string memory firstName, string memory lastName, uint releaseTime) public onlyparent {
        kidMapping[_kidAddress] = Kid(_kidAddress, firstName, lastName, releaseTime, 0);

        emit KidAdded(_kidAddress, firstName, lastName, releaseTime);
    }

    function depositToKid(address payable _kidAddress) payable public onlyparent {
        require(msg.value > 0, "amount should be greater than zero");
        kidMapping[_kidAddress].balance += msg.value;

        emit DepositToKidDone(_kidAddress, msg.value);
    }

    function getBalanceOfKid(address _kidAddress) public view returns(uint) {
        return kidMapping[_kidAddress].balance;
    }

    function getReleaseTime(address _kidAddress) public view returns(uint){
        return kidMapping[_kidAddress].releaseTime;
    }

    function withdraw(address payable _kidAddress) payable public nonReentrant {
        Kid memory _kid = kidMapping[_kidAddress];
        require(msg.sender == _kid.kidAddress, "you must be the kid to withdraw");
        require(block.timestamp > _kid.releaseTime, "you cannot withdraw yet");
        require(_kid.balance > 0, "balance should be greater than zero");
        payable(_kid.kidAddress).transfer(_kid.balance);
        kidMapping[_kidAddress].balance = 0;

        emit KidWithdrawalComplete(_kidAddress,_kid.balance);
    }
}
