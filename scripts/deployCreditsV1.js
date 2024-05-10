const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Credits", function () {
  let Credits;
  let credits;
  let Token;
  let token;
  let owner;
  let addr1;
  let addr2;
  let investContract;

  beforeEach(async function () {
    Token = await ethers.getContractFactory("ERC20PresetMinterPauser");
    token = await Token.deploy("USDT Token", "USDT");

    InvestContract = await ethers.getContractFactory("InvestContract");
    [owner, addr1, addr2] = await ethers.getSigners();

    investContract = await upgrades.deployProxy(InvestContract, [token.address], { initializer: "initialize" });

    Credits = await ethers.getContractFactory("Credits");
    credits = await Credits.deploy();
    await credits.initialize(token.address, investContract.address);

    await token.mint(addr1.address, ethers.utils.parseUnits("1000", 18));
    await token.connect(addr1).approve(investContract.address, ethers.utils.parseUnits("1000", 18));
  });

  it("Should issue credit correctly", async function () {
    await credits.issueCredit(addr1.address, ethers.utils.parseUnits("100", 18), ethers.utils.parseUnits("120", 18));

    const credit = await credits.credits(0);
    expect(credit.borrower).to.equal(addr1.address);
    expect(credit.amount).to.equal(ethers.utils.parseUnits("100", 18));
    expect(credit.repaymentAmount).to.equal(ethers.utils.parseUnits("120", 18));
  });

  it("Should repay credit correctly", async function () {
    await credits.issueCredit(addr1.address, ethers.utils.parseUnits("100", 18), ethers.utils.parseUnits("120", 18));

    await token.mint(addr1.address, ethers.utils.parseUnits("120", 18));
    await token.connect(addr1).approve(investContract.address, ethers.utils.parseUnits("120", 18));

    await credits.repayCredit(0, ethers.utils.parseUnits("120", 18));

    const credit = await credits.credits(0);
    expect(credit.repaid).to.be.true;
  });
});
