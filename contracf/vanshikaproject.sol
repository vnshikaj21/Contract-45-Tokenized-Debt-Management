// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenizedDebtManagement {

    // Token structure
    struct Debt {
        uint256 amount;
        uint256 dueDate;
        address creditor;
        bool isPaid;
    }

    mapping(address => Debt[]) public debts;
    mapping(address => uint256) public tokenBalances;
    
    event DebtCreated(address debtor, uint256 amount, uint256 dueDate, address creditor);
    event DebtPaid(address debtor, uint256 debtIndex);
    event TokenTransferred(address from, address to, uint256 amount);

    // Create a debt entry
    function createDebt(address _debtor, uint256 _amount, uint256 _dueDate, address _creditor) external {
        require(_debtor != address(0), "Invalid debtor address");
        require(_creditor != address(0), "Invalid creditor address");
        require(_amount > 0, "Debt amount should be greater than zero");
        
        Debt memory newDebt = Debt({
            amount: _amount,
            dueDate: _dueDate,
            creditor: _creditor,
            isPaid: false
        });
        
        debts[_debtor].push(newDebt);
        emit DebtCreated(_debtor, _amount, _dueDate, _creditor);
    }

    // Pay off a debt
    function payDebt(uint256 _debtIndex) external payable {
        require(_debtIndex < debts[msg.sender].length, "Invalid debt index");
        Debt storage debt = debts[msg.sender][_debtIndex];
        
        require(debt.isPaid == false, "Debt already paid");
        require(msg.value == debt.amount, "Incorrect payment amount");
        require(block.timestamp <= debt.dueDate, "Debt overdue");

        debt.isPaid = true;
        
        payable(debt.creditor).transfer(msg.value);
        
        emit DebtPaid(msg.sender, _debtIndex);
    }

    // Transfer tokens as payment (simplified for this example, assuming ERC-20 compliance)
    function transferTokens(address _to, uint256 _amount) external {
        require(tokenBalances[msg.sender] >= _amount, "Insufficient tokens");
        
        tokenBalances[msg.sender] -= _amount;
        tokenBalances[_to] += _amount;
        
        emit TokenTransferred(msg.sender, _to, _amount);
    }

    // Mint new tokens (admin only)
    function mintTokens(address _to, uint256 _amount) external {
        tokenBalances[_to] += _amount;
    }

    // Get all debts of an address
    function getDebts(address _debtor) external view returns (Debt[] memory) {
        return debts[_debtor];
    }
}
