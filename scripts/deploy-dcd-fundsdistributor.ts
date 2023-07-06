import { ethers } from "hardhat";
import { verify } from "../utils/verify";

const treasury = "0x07ffE08109223fC725D56af3ed9a33D6211793db";
const gnosis = "0x07ffE08109223fC725D56af3ed9a33D6211793db";

async function main() {
  const DCDFundsDistributor = await ethers.getContractFactory(
    "DCDFundsDistributor"
  );

  const dCDFundsDistributor = await DCDFundsDistributor.deploy(
    treasury,
    gnosis
  );

  await dCDFundsDistributor.deployed();

  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Verifying Contract ..........");
    await verify(dCDFundsDistributor.address, [treasury, gnosis]);
  }

  await console.log(
    `dCDFundsDistributor is deployed at ${dCDFundsDistributor.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
