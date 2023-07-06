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
      await digitalCitizenDAOERC721.mintToken(
        1,
        "0xD324eD52e4334C5db5992d875fFDd804802F005D",
        {
          value: "80000000000000000",
        }
      );

      const balance = await digitalCitizenDAOERC721.balanceOf(owner.address);

      expect(balance.toString()).to.equal("1");
    });

    it("it should check bounty system", async () => {
      await digitalCitizenDAOERC721.mintToken(
        1,
        "0xD324eD52e4334C5db5992d875fFDd804802F005D",
        {
          value: "80000000000000000",
        }
      );

      await digitalCitizenDAOERC721.updateTransferPause(false);

      await digitalCitizenDAOERC721.transferFrom(
        owner.address,
        "0xD324eD52e4334C5db5992d875fFDd804802F005D",
        1
      );

      await digitalCitizenDAOERC721.reveal();

      const tokenuri = await digitalCitizenDAOERC721.tokenURI(1);
      console.log(tokenuri.toString());

      await digitalCitizenDAOERC721
        .connect(addr1)
        .mintToken(1, "0xD324eD52e4334C5db5992d875fFDd804802F005D", {
          value: "80000000000000000",
        });

      const balance = await ethers.provider.getBalance(
        "0xD324eD52e4334C5db5992d875fFDd804802F005D"
      );

      expect(balance.toString()).to.equal("8000000000000000");
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
  });
});
