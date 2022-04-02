const { ethers } = require("hardhat")

const deployContract = async function (contractName, constructorArgs) {
  let factory = await ethers.getContractFactory(contractName)
  let contract = await factory.deploy(...(constructorArgs || []))
  await contract.deployed()
  return contract
}

module.exports = { deployContract }
