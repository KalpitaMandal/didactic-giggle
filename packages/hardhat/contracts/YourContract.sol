pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract YourContract is Ownable {

  event UpdateSuccessor(address owner, address newSuccessor);

  event StillAlive(address owner, uint256 aliveTill);

  address public successor;
  uint256 public aliveTill; 

  modifier onlySuccessor() {
    require(msg.sender == successor, 'Invalid Successor');
    _;
  }

  // string public purpose = "Building Unstoppable Apps!!!";

  constructor(address _successor) payable {
    successor = _successor;
    aliveTill = block.number;
    emit UpdateSuccessor(owner(), successor);
  }

  // still alive function wtihin 10 blocks time

  function stillAlive() public onlyOwner {
    uint256 currentBlock = block.number;
    if(currentBlock - aliveTill <= 10) {
      aliveTill = block.number;
      emit StillAlive(owner(), aliveTill);
    } else {
      // Renounce ownership to avoid any further calls
      renounceOwnership();
    }
  }

  function emptyFunds() public onlySuccessor {
    uint256 currentBlock = block.number;
    require(currentBlock - aliveTill > 10, 'Still Alive');

    // Getting the Eth balance and sending balance
    uint256 balance = address(this).balance;
    if(balance > 0) {
      (bool success, ) = successor.call{value: balance}('');
      require(success, 'Eth transfer failed');
    }

    // Send back rest of the crypto assets
    // emptyTokens();
  }

  function updateSuccessor(address newSuccessor) public onlyOwner {
    successor = newSuccessor;
    emit UpdateSuccessor(owner(), newSuccessor);
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}
