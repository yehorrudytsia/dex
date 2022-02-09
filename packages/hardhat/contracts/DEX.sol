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

  function ethToToken() public payable returns (uint256) {
    uint256 tokenReserve = token.balanceOf(address(this));
    uint tokensPurchased = price(msg.value, address(this).balance - msg.value, tokenReserve);
    require(token.transfer(msg.sender, tokensPurchased));
    return tokensPurchased;
  }

  function tokenToEth(uint256 tokens) public returns (uint256) {
    uint256 tokenReserve = token.balanceOf(address(this));
    uint256 ethPurchased = price(tokens, tokenReserve, address(this).balance);
    (bool sent,) = msg.sender.call{ value: ethPurchased }("");
    require(sent, "Failed to send Ether.");
    require(token.transferFrom(msg.sender, address(this), tokens));
    return ethPurchased;
  }

  function deposit() public payable returns (uint256) {
    uint256 ethReserve = address(this).balance - msg.value;
    uint256 tokenReserve = token.balanceOf(address(this));
    uint256 tokensAmount = ((msg.value * tokenReserve) / ethReserve) + 1; 
    uint256 liquidityMinted = (msg.value * totalLiquidity) / ethReserve;
    liquidity[msg.sender] += liquidityMinted;  
    totalLiquidity += liquidityMinted;
    require(token.transferFrom(msg.sender, address(this), tokensAmount));
    return liquidityMinted;  
  }
}