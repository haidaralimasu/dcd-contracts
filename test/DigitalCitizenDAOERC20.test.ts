import { ethers } from "hardhat";
import { expect } from "chai";
import { describe } from "mocha";

const TOTAL_SUPPLY = "400000000000000000000000000";

describe("Digital Citizen DAO ERC20 Unit Tests", async () => {
  let DigitalCitizenDAOERC20;
  let digitalCitizenDAOERC20;
  let owner;
  let treasury;
  let addr1;
  let addr2;
  let addr3;
  let uniswap;

  beforeEach(async () => {
    DigitalCitizenDAOERC20 = await ethers.getContractFactory(
      "DigitalCitizenDAOERC20"
    );
    [owner, addr1, addr2, addr3, treasury, uniswap] = await ethers.getSigners();

    digitalCitizenDAOERC20 = await DigitalCitizenDAOERC20.deploy();

    await digitalCitizenDAOERC20.deployed();
  });

  describe("Deployment and constructor", () => {
    it("it should check totalSupply", async () => {
      const totalSupply = await digitalCitizenDAOERC20.totalSupply();
      expect(totalSupply.toString()).to.equal(TOTAL_SUPPLY);
    });
  });

  describe("Fee and Exclude from fee", () => {
    it("it should check sell fee", async () => {
      await digitalCitizenDAOERC20.transfer(
        addr1.address,
        "100000000000000000000"
      );

      await digitalCitizenDAOERC20.setGetFee(addr3.address, true);
      await digitalCitizenDAOERC20.setMultipleGetFees(
        [uniswap.address, addr3.address],
        true
      );

      await digitalCitizenDAOERC20
        .connect(addr1)
        .transfer(uniswap.address, "100000000000000000000");

      const uniswapBalance = await digitalCitizenDAOERC20.balanceOf(
        uniswap.address
      );

      const treasuryBalance = await digitalCitizenDAOERC20.balanceOf(
        treasury.address
      );

      expect(uniswapBalance.toString()).to.equal("95000000000000000000");
      expect(treasuryBalance.toString()).to.equal("5000000000000000000");
    });

    it("it should check buy fee", async () => {
      await digitalCitizenDAOERC20.transfer(
        uniswap.address,
        "100000000000000000000"
      );

      await digitalCitizenDAOERC20.setGetFee(addr3.address, true);
      await digitalCitizenDAOERC20.setMultipleGetFees(
        [uniswap.address, addr3.address],
        true
      );

      await digitalCitizenDAOERC20
        .connect(uniswap)
        .transfer(addr1.address, "100000000000000000000");

      const addr1Balance = await digitalCitizenDAOERC20.balanceOf(
        addr1.address
      );

      const treasuryBalance = await digitalCitizenDAOERC20.balanceOf(
        treasury.address
      );

      expect(addr1Balance.toString()).to.equal("95000000000000000000");
      expect(treasuryBalance.toString()).to.equal("5000000000000000000");
    });

    it("it should check exclude from fee", async () => {
      await digitalCitizenDAOERC20.transfer(
        uniswap.address,
        "100000000000000000000"
      );

      await digitalCitizenDAOERC20.setGetFee(addr3.address, true);
      await digitalCitizenDAOERC20.setMultipleGetFees(
        [uniswap.address, addr3.address],
        true
      );

      await digitalCitizenDAOERC20.setExcludeFromFee(addr1.address, true);
      await digitalCitizenDAOERC20.setMultipleExcludeFromFees(
        [addr1.address, addr2.address],
        true
      );

      await digitalCitizenDAOERC20
        .connect(uniswap)
        .transfer(addr1.address, "100000000000000000000");

      const addr1Balance = await digitalCitizenDAOERC20.balanceOf(
        addr1.address
      );

      const treasuryBalance = await digitalCitizenDAOERC20.balanceOf(
        treasury.address
      );

      expect(addr1Balance.toString()).to.equal("100000000000000000000");
      expect(treasuryBalance.toString()).to.equal("0");
    });
  });
});
