import { task } from "hardhat/config";
import configts from "../config"

task("mint", "Mints tokens to address")
.addParam("address", "Address to mint to")
.addParam("amount", "Amount to mint")
.setAction(async (taskArgs, { ethers }) => {
  const token = await ethers.getContractAt("Token", configts.REWARDTOKENADDRESS)
  await token.mint(taskArgs.address, taskArgs.amount)
});

//npx hardhat --network rinkeby mint --address "0x830736E9E5A24cA5D653505bfD97A92df558b8DC" --amount "1000000000000000000000000"
