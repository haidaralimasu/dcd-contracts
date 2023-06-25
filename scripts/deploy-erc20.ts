import { ethers } from "hardhat";
import { verify } from "../utils/verify";

const treasury = "0x07ffE08109223fC725D56af3ed9a33D6211793db";

async function main() {
  const DigitalCitizenDAOERC20 = await ethers.getContractFactory(
    "DigitalCitizenDAOERC20"
  );

  const digitalCitizenDAOERC20 = await DigitalCitizenDAOERC20.deploy(treasury);

  await digitalCitizenDAOERC20.deployed();

  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Verifying Contract ..........");
    await verify(digitalCitizenDAOERC20.address, [treasury]);
  }

  await console.log(
    `Digital citizen ERC20 is deployed at ${digitalCitizenDAOERC20.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
