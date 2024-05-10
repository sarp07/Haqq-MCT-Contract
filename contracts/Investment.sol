// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./Credits.sol";

contract InvestContract is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    IERC20Upgradeable public token;
    Credits public creditsContract;

    uint256 public constant SERVICE_FEE_PERCENTAGE = 20;
    uint256 public constant PROFIT_PERCENTAGE = 4;
    address public moderator;

    struct Investment {
        uint256 investorId;
        address investorAddr;
        uint256 investAmount;
        uint256 investTime;
        uint256 loanStartTime;
        uint256 repaymentBudget;
        bool loanCircle;
        bool principalWithdrawn;
        bool profitWithdrawn;
    }

    mapping(address => Investment) public investments;
    mapping(address => bool) public moderators;
    uint256 public nextInvestorId;

    event InvestmentReceived(address indexed investor, uint256 amount);
    event CreditIssued(address indexed investor, uint256 amount);
    event CreditRepaid(address indexed investor, uint256 amount);
    event WithdrawalMade(address indexed investor, uint256 amount);
    event ModeratorAdded(address indexed moderator);
    event ModeratorRemoved(address indexed moderator);

    modifier onlyModerator() {
        require(moderators[msg.sender], "Not a moderator");
        _;
    }

    function initialize(address _token, address _creditsContract) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        token = IERC20Upgradeable(_token);
        creditsContract = Credits(_creditsContract);
        moderator = msg.sender;
        addModerator(msg.sender);
    }

    function setModerator(address _moderator) external onlyOwner {
        moderator = _moderator;
    }

    function invest(uint256 amount, uint256 _loanStartTime, uint256 _repaymentBudget, bool _loanCircle) external nonReentrant {
        require(amount > 0, "Investment amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        investments[msg.sender] = Investment({
            investorId: nextInvestorId,
            investorAddr: msg.sender,
            investAmount: amount,
            investTime: block.timestamp,
            loanStartTime: _loanStartTime,
            repaymentBudget: _repaymentBudget,
            loanCircle: _loanCircle,
            principalWithdrawn: false,
            profitWithdrawn: false
        });

        nextInvestorId++;
        emit InvestmentReceived(msg.sender, amount);
    }

    function issueCredit(address investor, uint256 amount) external onlyModerator {
        require(investments[investor].investAmount >= amount, "Insufficient funds");
        investments[investor].repaymentBudget += amount;

        uint256 repaymentAmount = amount + (amount * SERVICE_FEE_PERCENTAGE) / 100;
        creditsContract.issueCredit(investor, amount, repaymentAmount);

        emit CreditIssued(investor, amount);
    }

    function repayCredit(address investor, uint256 amount) external onlyModerator {
        Investment storage investment = investments[investor];
        require(investment.repaymentBudget >= amount, "Invalid amount");

        creditsContract.repayCredit(investor, amount);

        investment.repaymentBudget -= amount;
        investment.investAmount += amount;
        investment.profitWithdrawn = false;

        emit CreditRepaid(investor, amount);
    }

    function withdrawPrincipal() external nonReentrant {
        Investment storage investment = investments[msg.sender];
        require(!investment.principalWithdrawn, "Principal already withdrawn");
        require(investment.investAmount > 0, "No principal to withdraw");

        uint256 principal = investment.investAmount;
        investment.investAmount = 0;
        investment.principalWithdrawn = true;

        token.transfer(msg.sender, principal);
        emit WithdrawalMade(msg.sender, principal);
    }

    function withdrawProfit() external nonReentrant {
        Investment storage investment = investments[msg.sender];
        require(!investment.profitWithdrawn, "Profit already withdrawn");

        uint256 profit = (investment.investAmount * PROFIT_PERCENTAGE) / 100;
        investment.profitWithdrawn = true;

        token.transfer(msg.sender, profit);
        emit WithdrawalMade(msg.sender, profit);
    }

    function addModerator(address _moderator) public onlyOwner {
        moderators[_moderator] = true;
        emit ModeratorAdded(_moderator);
    }

    function removeModerator(address _moderator) public onlyOwner {
        moderators[_moderator] = false;
        emit ModeratorRemoved(_moderator);
    }

    function withdrawUSDT(uint256 amount) public onlyModerator nonReentrant {
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance in the pool");
        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit WithdrawalMade(msg.sender, amount);
    }
}
