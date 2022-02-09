// deploy/00_deploy_balloons_dex.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("Balloons", {
    from: deployer,
    log: true,
  });

  const balloons = await ethers.getContract("Balloons", deployer);

  await deploy("DEX", {
    from: deployer,
    args: [balloons.address],
    log: true,
  });

  // const dex = await ethers.getContract("DEX", deployer);


  await balloons.transfer("0x744803E078BaF3d3209c71a7876e53b9c55E6949",""+(10*10**18));

  // uncomment to init DEX on deploy:
  // console.log("Approving DEX ("+dex.address+") to take Balloons from main account...")
  // If you are going to the testnet make sure your deployer account has enough ETH
  // await balloons.approve(dex.address,ethers.utils.parseEther('100'));
  // console.log("INIT exchange...")
  // await dex.init(""+(3*10**18),{value:ethers.utils.parseEther('3'),gasLimit:200000})
};
module.exports.tags = ["Balloons", "DEX"];
