// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract LoanTracking is Initializable, Ownable {
    struct Loan {
        address investor;
        uint256 loanAmount;
        uint256 totalInstallments;
        uint256 remainingInstallments;
        uint256 totalPayments;
        uint256 serviceFee;
        uint256 totalRepaid;
    }

    mapping(address => Loan) public loans;
    mapping(address => bool) public moderators;

    event LoanIssued(address borrower, address investor, uint256 loanAmount);
    event PaymentMade(address borrower, uint256 amount);
    event ModeratorAdded(address moderator);
    event ModeratorRemoved(address moderator);

    function initialize() initializer public {
        __Ownable_init();
    }

    modifier onlyModerator() {
        require(moderators[msg.sender], "Caller is not a moderator");
        _;
    }

    function addModerator(address _moderator) external onlyOwner {
        moderators[_moderator] = true;
        emit ModeratorAdded(_moderator);
    }

    function removeModerator(address _moderator) external onlyOwner {
        moderators[_moderator] = false;
        emit ModeratorRemoved(_moderator);
    }

    function issueLoan(
        address _borrower,
        address _investor,
        uint256 _loanAmount,
        uint256 _totalInstallments,
        uint256 _serviceFee
    ) external onlyModerator {
        loans[_borrower] = Loan({
            investor: _investor,
            loanAmount: _loanAmount,
            totalInstallments: _totalInstallments,
            remainingInstallments: _totalInstallments,
            totalPayments: 0,
            serviceFee: _serviceFee,
            totalRepaid: 0
        });
        emit LoanIssued(_borrower, _investor, _loanAmount);
    }

    function makePayment(address _borrower, uint256 _amount) external onlyModerator {
        require(loans[_borrower].remainingInstallments > 0, "No remaining installments");
        loans[_borrower].totalPayments += _amount;
        loans[_borrower].remainingInstallments--;
        loans[_borrower].totalRepaid += _amount;
        emit PaymentMade(_borrower, _amount);
    }

    function getLoanDetails(address _borrower) external view returns (Loan memory) {
        return loans[_borrower];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}