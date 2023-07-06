import { ethers } from "hardhat";
import { expect } from "chai";
import { describe } from "mocha";

const treasury = "0xe3E03958Cb7C6c8506F4a0Cc0c7a2Ad7170310d2";
const gnosis = "0xD324eD52e4334C5db5992d875fFDd804802F005D";

describe("DCD Funds Distributor", async () => {
  let DigitalCitizenDAOERC20;
  let digitalCitizenDAOERC20;
  let DCDFundsDistributor;
  let dCDFundsDistributor;
  let owner;
  let addr1;
  let addr2;
  let addr3;

  beforeEach(async () => {
    DigitalCitizenDAOERC20 = await ethers.getContractFactory(
      "DigitalCitizenDAOERC20"
    );
    DCDFundsDistributor = await ethers.getContractFactory(
      "DCDFundsDistributor"
    );
    [owner, addr1, addr2, addr3] = await ethers.getSigners();

    digitalCitizenDAOERC20 = await DigitalCitizenDAOERC20.deploy();

    dCDFundsDistributor = await DCDFundsDistributor.deploy(treasury, gnosis);

    await dCDFundsDistributor.deployed();
    await digitalCitizenDAOERC20.deployed();
  });

  describe("should check distribution of funds", () => {
    it("it should check distribution of eth", async () => {
      await dCDFundsDistributor.deposite({ value: "100000000000000000000" });
      await dCDFundsDistributor.distributeETH();

      expect(await ethers.provider.getBalance(gnosis)).to.equal(
        "2500000000000000000"
      );
      expect(await ethers.provider.getBalance(treasury)).to.equal(
        "97500000000000000000"
      );
    });
  });
});
