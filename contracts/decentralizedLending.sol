// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedLending is Ownable {
    struct Loan {
        address borrower;
        uint256 principal;
        uint256 collateral;
        uint256 interestRate; // in basis points (e.g., 500 for 5%)
        uint256 startTime;
        bool isActive;
    }

    mapping(address => Loan) public loans;
    IERC20 public collateralToken;
    IERC20 public lendingToken;

    constructor(IERC20 _collateralToken, IERC20 _lendingToken) Ownable(msg.sender) {
        collateralToken = _collateralToken;
        lendingToken = _lendingToken;
    }

    function requestLoan(uint256 _principal, uint256 _collateral, uint256 _interestRate) external {
        require(!loans[msg.sender].isActive, "Existing loan active");

        require(collateralToken.transferFrom(msg.sender, address(this), _collateral), "Collateral transfer failed");
        require(lendingToken.transfer(msg.sender, _principal), "Lending transfer failed");

        loans[msg.sender] = Loan({
            borrower: msg.sender,
            principal: _principal,
            collateral: _collateral,
            interestRate: _interestRate,
            startTime: block.timestamp,
            isActive: true
        });
    }

    function repayLoan() external {
        Loan storage loan = loans[msg.sender];
        require(loan.isActive, "No active loan");

        uint256 interest = calculateInterest(loan.principal, loan.interestRate, block.timestamp - loan.startTime);
        uint256 totalRepayment = loan.principal + interest;

        require(lendingToken.transferFrom(msg.sender, address(this), totalRepayment), "Repayment transfer failed");
        require(collateralToken.transfer(msg.sender, loan.collateral), "Collateral return failed");

        loan.isActive = false;
    }

    function liquidateLoan(address _borrower) external onlyOwner {
        Loan storage loan = loans[_borrower];
        require(loan.isActive, "No active loan");
        require(isCollateralInsufficient(_borrower), "Collateral is sufficient");

        require(collateralToken.transfer(owner(), loan.collateral), "Collateral transfer failed");
        loan.isActive = false;
    }

    function calculateInterest(uint256 _principal, uint256 _interestRate, uint256 _timeElapsed) internal pure returns (uint256) {
        return _principal * _interestRate * _timeElapsed / 365 days / 10000;
    }

    function isCollateralInsufficient(address _borrower) public view returns (bool) {
        Loan storage loan = loans[_borrower];
        uint256 requiredCollateral = loan.principal + calculateInterest(loan.principal, loan.interestRate, block.timestamp - loan.startTime);
        return loan.collateral < requiredCollateral;
    }
}
