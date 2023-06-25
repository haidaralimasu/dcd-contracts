import { ethers } from "hardhat";
import { verify } from "../utils/verify";

const proxyRegistery = "0x07ffE08109223fC725D56af3ed9a33D6211793db";

async function main() {
  const DigitalCitizenDAOERC721 = await ethers.getContractFactory(
    "DigitalCitizenDAOERC721"
  );

  const digitalCitizenDAOERC721 = await DigitalCitizenDAOERC721.deploy(
    proxyRegistery
  );

  await digitalCitizenDAOERC721.deployed();

  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Verifying Contract ..........");
    await verify(digitalCitizenDAOERC721.address, [proxyRegistery]);
  }

  await console.log(
    `Digital citizen ERC20 is deployed at ${digitalCitizenDAOERC721.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
