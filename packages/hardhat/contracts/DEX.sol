pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {

  IERC20 token;

  uint256 public totalLiquidity;
  mapping (address => uint256) public liquidity;

  constructor(address token_addr) {
    token = IERC20(token_addr);
  }

  function init(uint256 tokens) public payable returns (uint256) {
    require(totalLiquidity==0,"DEX:init - already has liquidity");
    totalLiquidity = address(this).balance;
    liquidity[msg.sender] = totalLiquidity;
    require(token.transferFrom(msg.sender, address(this), tokens));
    return totalLiquidity;
  }

  function price(uint256 amount, uint256 inputReserve, uint256 outputReserve) 
    public
    view 
    returns (uint256) 
  {
    uint256 inputAmount = amount * 997; // adding fee (0.3%)
    uint256 numerator = inputAmount * outputReserve;
    uint256 denominator = inputReserve * 1000 + inputAmount;
    return numerator / denominator;
  }
}