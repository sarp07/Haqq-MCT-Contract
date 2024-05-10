// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract Credits is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    IERC20Upgradeable public token;

    struct Credit {
        address borrower;
        uint256 amount;
        uint256 startTime;
        uint256 repaymentAmount;
        bool repaid;
    }

    mapping(uint256 => Credit) public credits;
    uint256 public nextCreditId;
    address public investContract;

    event CreditIssued(uint256 indexed creditId, address indexed borrower, uint256 amount);
    event CreditRepaid(uint256 indexed creditId, address indexed borrower, uint256 amount);

    modifier onlyInvestContract() {
        require(msg.sender == investContract, "Only the InvestContract can call this function");
        _;
    }

    function initialize(address _token, address _investContract) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        token = IERC20Upgradeable(_token);
        investContract = _investContract;
    }

    function issueCredit(address borrower, uint256 amount, uint256 repaymentAmount) external onlyInvestContract {
        require(amount > 0, "Credit amount must be greater than 0");

        credits[nextCreditId] = Credit({
            borrower: borrower,
            amount: amount,
            startTime: block.timestamp,
            repaymentAmount: repaymentAmount,
            repaid: false
        });

        token.transfer(borrower, amount);

        emit CreditIssued(nextCreditId, borrower, amount);
        nextCreditId++;
    }

    function repayCredit(uint256 creditId, uint256 amount) external onlyInvestContract {
        Credit storage credit = credits[creditId];
        require(credit.amount > 0, "Credit not found");
        require(!credit.repaid, "Credit already repaid");
        require(amount >= credit.repaymentAmount, "Repayment amount is less than required");

        credit.repaid = true;

        token.transferFrom(credit.borrower, investContract, amount);

        emit CreditRepaid(creditId, credit.borrower, amount);
    }
}
