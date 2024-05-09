// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MicroCreditPlatform is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    IERC20Upgradeable public usdtToken;

    struct Investor {
        uint256 totalInvested;
        uint256 totalCreditsUsed;
        uint256 lastInvestmentTime;
        uint256 earnings;
    }

    mapping(address => Investor) public investors;
    mapping(address => bool) public moderators;

    event InvestmentReceived(address indexed investor, uint256 amount);
    event CreditIssued(address indexed investor, uint256 amount);
    event CreditRepaid(address indexed investor, uint256 amount);
    event WithdrawalMade(address indexed investor, uint256 amount);

    function initialize(address usdtAddress) public initializer {
        usdtToken = IERC20Upgradeable(usdtAddress);
        __Ownable_init();
        __ReentrancyGuard_init();
        moderators[msg.sender] = true;
    }

    function invest(uint256 amount) public nonReentrant {
        require(
            usdtToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        Investor storage investor = investors[msg.sender];
        investor.totalInvested += amount;
        investor.lastInvestmentTime = block.timestamp;
        emit InvestmentReceived(msg.sender, amount);
    }

    function issueCredit(
        address investor,
        uint256 amount
    ) public onlyModerator {
        require(
            investors[investor].totalInvested >= amount,
            "Insufficient funds"
        );
        investors[investor].totalCreditsUsed += amount;
        emit CreditIssued(investor, amount);
    }

    function repayCredit(
        address investor,
        uint256 amount
    ) public onlyModerator {
        require(
            investors[investor].totalCreditsUsed >= amount,
            "Invalid amount"
        );
        investors[investor].totalCreditsUsed -= amount;
        investors[investor].earnings += calculateEarnings(amount);
        emit CreditRepaid(investor, amount);
    }

    function calculateEarnings(uint256 amount) internal pure returns (uint256) {
        return (amount * 4) / 100;
    }

    function withdrawInvestment(uint256 amount) public nonReentrant {
        Investor storage investor = investors[msg.sender];
        require(
            block.timestamp >= investor.lastInvestmentTime + 48 weeks,
            "Withdrawal locked"
        );
        require(investor.totalInvested >= amount, "Insufficient funds");
        require(usdtToken.transfer(msg.sender, amount), "Transfer failed");
        investor.totalInvested -= amount;
        emit WithdrawalMade(msg.sender, amount);
    }

    function addModerator(address _mod) public onlyOwner {
        moderators[_mod] = true;
    }

    function removeModerator(address _mod) public onlyOwner {
        moderators[_mod] = false;
    }

    modifier onlyModerator() {
        require(moderators[msg.sender], "Not a moderator");
        _;
    }

    function withdrawUSDT(uint256 amount) public onlyModerator {
        require(
            usdtToken.balanceOf(address(this)) >= amount,
            "Insufficient balance in the pool"
        );
        require(usdtToken.transfer(msg.sender, amount), "Transfer failed");
        emit WithdrawalMade(msg.sender, amount);
    }
}
