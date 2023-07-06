import { ethers } from "hardhat";
import { expect } from "chai";
import { describe } from "mocha";

const TOTAL_SUPPLY = "400000000000000000000000000";

const proxyRegistery = "0x1E0049783F008A0085193E00003D00cd54003c71";
const DELAY = 172800;
const VOTING_PERIOD = 5760;
const VOTING_DELAY = 13140;
const PROPOSALS_THERSHOLD_BPS = 500;
const QOURAM_VOTES = 5100;

describe("Digital Citizen DAO ERC20 Unit Tests", async () => {
  let DigitalCitizenDAOERC20;
  let digitalCitizenDAOERC20;
  let DigitalCitizenDAOERC721;
  let digitalCitizenDAOERC721;
  let DigitalCitizenDAOLogic;
  let digitalCitizenDAOLogic;
  let DigitalCitizenDAOProxy;
  let digitalCitizenDAOProxy;
  let DigitalCitizenDAOExecutor;
  let digitalCitizenDAOExecutor;
  let owner;
  let treasury;
  let addr1;
  let addr2;
  let addr3;
  let uniswap;

  beforeEach(async () => {
    [owner, addr1, addr2, addr3, treasury, uniswap] = await ethers.getSigners();

    DigitalCitizenDAOLogic = await ethers.getContractFactory(
      "DigitalCitizenDAOLogic"
    );

    DigitalCitizenDAOProxy = await ethers.getContractFactory(
      "DigitalCitizenDAOProxy"
    );
    DigitalCitizenDAOExecutor = await ethers.getContractFactory(
      "DigitalCitizenDAOExecutor"
    );
    DigitalCitizenDAOERC721 = await ethers.getContractFactory(
      "DigitalCitizenDAOERC721"
    );
    DigitalCitizenDAOERC20 = await ethers.getContractFactory(
      "DigitalCitizenDAOERC20"
    );

    digitalCitizenDAOERC721 = await DigitalCitizenDAOERC721.deploy(
      proxyRegistery
    );

    await digitalCitizenDAOERC721.deployed();

    digitalCitizenDAOERC20 = await DigitalCitizenDAOERC20.deploy();

    await digitalCitizenDAOERC20.deployed();

    const nonce = await owner.getTransactionCount();

    const expectedNounsDAOProxyAddress = ethers.utils.getContractAddress({
      from: owner.address,
      nonce: nonce + 2,
    });

    digitalCitizenDAOExecutor = await DigitalCitizenDAOExecutor.deploy(
      expectedNounsDAOProxyAddress,
      DELAY
    );

    await digitalCitizenDAOExecutor.deployed();

    digitalCitizenDAOLogic = await DigitalCitizenDAOLogic.deploy();
    await digitalCitizenDAOLogic.deployed();

    digitalCitizenDAOProxy = await DigitalCitizenDAOProxy.deploy(
      digitalCitizenDAOExecutor.address,
      digitalCitizenDAOERC721.address,
      owner.address,
      digitalCitizenDAOExecutor.address,
      digitalCitizenDAOLogic.address,
      VOTING_PERIOD,
      VOTING_DELAY,
      PROPOSALS_THERSHOLD_BPS,
      QOURAM_VOTES
    );

    await digitalCitizenDAOProxy.deployed();
  });

  describe("Propose", () => {
    it("it should check propose function", async () => {
      await digitalCitizenDAOERC721.mintToken(1, {
        value: "80000000000000000",
      });

      const contract = await ethers.getContractFactory(
        "DigitalCitizenDAOLogic"
      );
      const proxy = await contract.attach(digitalCitizenDAOProxy.address);

      await proxy.propose(
        [owner.address],
        ["1000000000000000000"],
        [""],
        ["0x"],
        "Test description"
      );
    });
  });
});
