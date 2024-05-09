const { ethers, upgrades } = require("hardhat");

async function main() {
  const InvestmentPool = await ethers.getContractFactory("InvestmentPool");
  console.log("Deploying InvestmentPool...");

  const investmentPool = await upgrades.deployProxy(InvestmentPool, [], {
    initializer: "initialize",
  });

  await investmentPool.deployed();

  console.log("InvestmentPool deployed to:", investmentPool.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
