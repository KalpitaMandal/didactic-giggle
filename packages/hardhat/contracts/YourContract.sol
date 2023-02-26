pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

contract YourContract is Ownable {
  using SafeERC20 for IERC20;

  event UpdateSuccessor(address owner, address newSuccessor);

  event StillAlive(address owner, uint256 aliveTill);

  address public successor;
  uint256 public aliveTill; 

  constructor(address _successor) payable {
    successor = _successor;
    aliveTill = block.number + 10;
    emit UpdateSuccessor(owner(), successor);
  }

  function stillAlive() public onlyOwner {
    uint256 currentBlock = block.number;
    if(currentBlock - aliveTill <= 10) {
      aliveTill = block.number + 10;
      emit StillAlive(owner(), aliveTill);
    } else {
      // Renounce ownership to avoid any further calls
      renounceOwnership();
      emptyFunds();
    }
  }

  function emptyFunds() public {
    uint256 currentBlock = block.number;
    require(currentBlock - aliveTill > 10, 'Still Alive');

    // Getting the Eth balance and sending balance
    uint256 balance = address(this).balance;
    if(balance > 0) {
      (bool success, ) = successor.call{value: balance}('');
      require(success, 'Eth transfer failed');
    }
  }

  function emptyCrypto(address asset) public {
    uint256 currentBlock = block.number;
    require(currentBlock - aliveTill > 10, 'Still Alive');

    // Getting the crypto balance and sending balance
    uint256 balance = IERC20(asset).balanceOf(address(this));
    if(balance > 0) {
      // Approving the receiver contract to manage the received crypto
      IERC20(asset).safeApprove(successor, balance);

      // Sending the crypto funds
      IERC20(asset).safeTransferFrom( address(this), successor, balance);
    }
  }

  function updateSuccessor(address newSuccessor) public onlyOwner {
    successor = newSuccessor;
    emit UpdateSuccessor(owner(), newSuccessor);
  }

  // to support receiving ETH by default
  receive() external payable {}
}
