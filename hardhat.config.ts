/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { HardhatUserConfig } from "hardhat/config";
const dotenv = require("dotenv");
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import "@float-capital/solidity-coverage";
import "@typechain/hardhat";
import "hardhat-abi-exporter";
import "hardhat-gas-reporter";
import "@openzeppelin/hardhat-upgrades";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10_000,
      },
    },
  },
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: [process.env.WALLET_PRIVATE_KEY!].filter(Boolean),
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: process.env.MNEMONIC
        ? { mnemonic: process.env.MNEMONIC }
        : [process.env.WALLET_PRIVATE_KEY!].filter(Boolean),
    },
    hardhat: {
      initialBaseFeePerGas: 0,
      forking: {
        url: `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      },
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  abiExporter: {
    path: "./abi",
    clear: true,
  },
  typechain: {
    outDir: "./typechain",
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    gasPrice: 50,
    src: "contracts",
    coinmarketcap: "7643dfc7-a58f-46af-8314-2db32bdd18ba",
  },
  mocha: {
    timeout: 60_000,
  },
};
export default config;
