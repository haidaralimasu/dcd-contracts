import { ethers, upgrades } from "hardhat";
import { verify } from "../utils/verify";

const proxyRegistery = "0x1E0049783F008A0085193E00003D00cd54003c71";
const DELAY = 172800;
const VOTING_PERIOD = 5760;
const VOTING_DELAY = 13140;
const PROPOSALS_THERSHOLD_BPS = 500;
const QOURAM_VOTES = 5100;

async function main() {
  const [deployer] = await ethers.getSigners();

  const DigitalCitizenDAOLogic = await ethers.getContractFactory(
    "DigitalCitizenDAOLogic"
  );

  const DigitalCitizenDAOProxy = await ethers.getContractFactory(
    "DigitalCitizenDAOProxy"
  );
  const DigitalCitizenDAOExecutor = await ethers.getContractFactory(
    "DigitalCitizenDAOExecutor"
  );
  const DigitalCitizenDAOERC721 = await ethers.getContractFactory(
    "DigitalCitizenDAOERC721"
  );
  const DigitalCitizenDAOERC20 = await ethers.getContractFactory(
    "DigitalCitizenDAOERC20"
  );

  const digitalCitizenDAOERC721 = await DigitalCitizenDAOERC721.deploy(
    proxyRegistery
  );

  await digitalCitizenDAOERC721.deployed();

  const digitalCitizenDAOERC20 = await DigitalCitizenDAOERC20.deploy();

  await digitalCitizenDAOERC20.deployed();

  const nonce = await deployer.getTransactionCount();

  const expectedNounsDAOProxyAddress = ethers.utils.getContractAddress({
    from: deployer.address,
    nonce: nonce + 2,
  });

  console.log(expectedNounsDAOProxyAddress, "HJKHHHUIIUHUIHIUHIUGH");

  const digitalCitizenDAOExecutor = await DigitalCitizenDAOExecutor.deploy(
    expectedNounsDAOProxyAddress,
    DELAY
  );

  await digitalCitizenDAOExecutor.deployed();

  const digitalCitizenDAOLogic = await DigitalCitizenDAOLogic.deploy();
  await digitalCitizenDAOLogic.deployed();

  const digitalCitizenDAOProxy = await DigitalCitizenDAOProxy.deploy(
    digitalCitizenDAOExecutor.address,
    digitalCitizenDAOERC721.address,
    deployer.address,
    digitalCitizenDAOExecutor.address,
    digitalCitizenDAOLogic.address,
    VOTING_PERIOD,
    VOTING_DELAY,
    PROPOSALS_THERSHOLD_BPS,
    QOURAM_VOTES
  );

  await digitalCitizenDAOProxy.deployed();

  console.log(`ERC721: ${digitalCitizenDAOERC721.address}`);
  console.log(`ERC20: ${digitalCitizenDAOERC20.address}`);
  console.log(`Executor: ${digitalCitizenDAOExecutor.address}`);
  console.log(`Implementation: ${digitalCitizenDAOLogic.address}`);
  console.log(`Proxy: ${digitalCitizenDAOProxy.address}`);

  if (process.env.ETHERSCAN_API_KEY) {
    console.log("Verifying Contracts......");
    await verify(digitalCitizenDAOERC20.address, []);
    await verify(digitalCitizenDAOERC721.address, [proxyRegistery]);
    await verify(digitalCitizenDAOLogic.address, []);
    await verify(digitalCitizenDAOExecutor.address, [
      digitalCitizenDAOProxy.address,
      DELAY,
    ]);
    await verify(digitalCitizenDAOProxy.address, [
      digitalCitizenDAOExecutor.address,
      digitalCitizenDAOERC721.address,
      deployer.address,
      digitalCitizenDAOExecutor.address,
      digitalCitizenDAOLogic.address,
      VOTING_PERIOD,
      VOTING_DELAY,
      PROPOSALS_THERSHOLD_BPS,
      QOURAM_VOTES,
    ]);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
