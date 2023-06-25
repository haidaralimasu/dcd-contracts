import { ethers } from "hardhat";
import { expect } from "chai";
import { describe } from "mocha";

const I_PROXY_REGISTERY = "0xD324eD52e4334C5db5992d875fFDd804802F005D";

describe("Digital Citizen DAO ERC721 Unit Tests", async () => {
  let DigitalCitizenDAOERC721;
  let digitalCitizenDAOERC721;
  let owner;
  let addr1;
  let addr2;
  let addr3;

  beforeEach(async () => {
    DigitalCitizenDAOERC721 = await ethers.getContractFactory(
      "DigitalCitizenDAOERC721"
    );
    [owner, addr1, addr2, addr3] = await ethers.getSigners();

    digitalCitizenDAOERC721 = await DigitalCitizenDAOERC721.deploy(
      I_PROXY_REGISTERY
    );

    await digitalCitizenDAOERC721.deployed();
  });

  describe("mint and transfer functions", () => {
    it("it should check mint", async () => {
      await digitalCitizenDAOERC721.mintToken(1, {
        value: "80000000000000000",
      });

      const balance = await digitalCitizenDAOERC721.balanceOf(owner.address);

      expect(balance.toString()).to.equal("1");
    });

    it("it should check transfer paused", async () => {
      await digitalCitizenDAOERC721.mintToken(1, {
        value: "80000000000000000",
      });

      await expect(
        digitalCitizenDAOERC721.transferFrom(owner.address, addr1.address, 1)
      ).to.revertedWith("You cannot transfer right now");
    });

    it("it should check transfer unpaused", async () => {
      await digitalCitizenDAOERC721.mintToken(1, {
        value: "80000000000000000",
      });

      await digitalCitizenDAOERC721.updateTransferPause(false);

      await digitalCitizenDAOERC721.transferFrom(
        owner.address,
        addr1.address,
        1
      );
    });

    // it("it should check exclude from fee", async () => {
    //   await digitalCitizenDAOERC20.transfer(
    //     uniswap.address,
    //     "100000000000000000000"
    //   );

    //   await digitalCitizenDAOERC20.setGetFee(addr3.address, true);
    //   await digitalCitizenDAOERC20.setMultipleGetFees(
    //     [uniswap.address, addr3.address],
    //     true
    //   );

    //   await digitalCitizenDAOERC20.setExcludeFromFee(addr1.address, true);
    //   await digitalCitizenDAOERC20.setMultipleExcludeFromFees(
    //     [addr1.address, addr2.address],
    //     true
    //   );

    //   await digitalCitizenDAOERC20
    //     .connect(uniswap)
    //     .transfer(addr1.address, "100000000000000000000");

    //   const addr1Balance = await digitalCitizenDAOERC20.balanceOf(
    //     addr1.address
    //   );

    //   const treasuryBalance = await digitalCitizenDAOERC20.balanceOf(
    //     treasury.address
    //   );

    //   expect(addr1Balance.toString()).to.equal("100000000000000000000");
    //   expect(treasuryBalance.toString()).to.equal("0");
    // });
  });
});
