const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("InvestContract", function () {
  let InvestContract;
  let investContract;
  let Token;
  let token;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    Token = await ethers.getContractFactory("ERC20PresetMinterPauser");
    token = await Token.deploy("USDT Token", "USDT");

    InvestContract = await ethers.getContractFactory("InvestContract");
    [owner, addr1, addr2] = await ethers.getSigners();

    investContract = await upgrades.deployProxy(InvestContract, [token.address], { initializer: "initialize" });

    await token.mint(addr1.address, ethers.utils.parseUnits("1000", 18));
    await token.connect(addr1).approve(investContract.address, ethers.utils.parseUnits("1000", 18));
  });

  it("Should allow user to invest", async function () {
    await investContract.connect(addr1).invest(
      ethers.utils.parseUnits("100", 18),
      Math.floor(Date.now() / 1000) + 3600,
      1000,
      true
    );

    const investment = await investContract.investments(addr1.address);
    expect(investment.investAmount).to.equal(ethers.utils.parseUnits("100", 18));
  });

  it("Should allow moderator to issue credit", async function () {
    await investContract.connect(addr1).invest(
      ethers.utils.parseUnits("100", 18),
      Math.floor(Date.now() / 1000) + 3600,
      1000,
      true
    );

    await investContract.issueCredit(addr1.address, ethers.utils.parseUnits("50", 18));

    const investment = await investContract.investments(addr1.address);
    expect(investment.repaymentBudget).to.equal(ethers.utils.parseUnits("50", 18));
  });

  it("Should allow user to withdraw principal", async function () {
    await investContract.connect(addr1).invest(
      ethers.utils.parseUnits("100", 18),
      Math.floor(Date.now() / 1000) + 3600,
      1000,
      true
    );

    await investContract.connect(addr1).withdrawPrincipal();

    const investment = await investContract.investments(addr1.address);
    expect(investment.investAmount).to.equal(0);
  });

  it("Should allow user to withdraw profit", async function () {
    await investContract.connect(addr1).invest(
      ethers.utils.parseUnits("100", 18),
      Math.floor(Date.now() / 1000) + 3600,
      1000,
      true
    );

    await investContract.issueCredit(addr1.address, ethers.utils.parseUnits("50", 18));
    await investContract.repayCredit(addr1.address, ethers.utils.parseUnits("50", 18));

    await investContract.connect(addr1).withdrawProfit();

    const investment = await investContract.investments(addr1.address);
    expect(investment.profitWithdrawn).to.be.true;
  });
});
