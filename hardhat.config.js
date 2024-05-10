require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    haqq_testnet: {
      url: "https://rpc.eth.testedge2.haqq.network",
      ethNetwork: "testnet",
      chainId: 54211,
      accounts: [process.env.PRIVATE_KEY],
    },
    haqq_mainnet: {
      url: "https://rpc.eth.haqq.network",
      ethNetwork: "mainnet",
      chainId: 11235,
      accounts: [process.env.PRIVATE_KEY],
    },
    mumbai: {
      url: "https://polygon-mumbai.gateway.tenderly.co",
      ethNetwork: "testnet",
      chainId: "80001",
      accounts: [process.env.PRIVATE_KEY],
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
};
