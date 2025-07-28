// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title DecentralizedCalculator
 * @dev A smart contract that performs basic and scientific calculations with history tracking
 * @author Your Name
 */
contract DecentralizedCalculator {
    
    // Structure to store calculation history
    struct Calculation {
        string operation;
        int256 operand1;
        int256 operand2;
        int256 result;
        uint256 timestamp;
        address user;
    }
    
    // Mapping to store user's calculation history
    mapping(address => Calculation[]) private userHistory;
    
    // Global calculation counter
    uint256 public totalCalculations;
    
    // Events for logging calculations
    event BasicCalculation(address indexed user, string operation, int256 operand1, int256 operand2, int256 result);
    event ScientificCalculation(address indexed user, string operation, int256 operand, int256 result);
    
    /**
     * @dev Performs basic arithmetic operations (addition, subtraction, multiplication, division)
     * @param _operand1 First number
     * @param _operand2 Second number
     * @param _operation Operation type: "add", "sub", "mul", "div"
     * @return result The result of the calculation
     */
    function basicArithmetic(int256 _operand1, int256 _operand2, string memory _operation) 
        public 
        returns (int256 result) 
    {
        require(bytes(_operation).length > 0, "Operation cannot be empty");
        
        if (keccak256(abi.encodePacked(_operation)) == keccak256(abi.encodePacked("add"))) {
            result = _operand1 + _operand2;
        } else if (keccak256(abi.encodePacked(_operation)) == keccak256(abi.encodePacked("sub"))) {
            result = _operand1 - _operand2;
        } else if (keccak256(abi.encodePacked(_operation)) == keccak256(abi.encodePacked("mul"))) {
            result = _operand1 * _operand2;
        } else if (keccak256(abi.encodePacked(_operation)) == keccak256(abi.encodePacked("div"))) {
            require(_operand2 != 0, "Division by zero is not allowed");
            result = _operand1 / _operand2;
        } else {
            revert("Invalid operation. Use: add, sub, mul, div");
        }
        
        // Store in history
        _storeCalculation(_operation, _operand1, _operand2, result);
        
        emit BasicCalculation(msg.sender, _operation, _operand1, _operand2, result);
        
        return result;
    }
    
    /**
     * @dev Performs scientific functions (power, square root approximation, absolute value)
     * @param _operand The number to perform operation on
     * @param _operation Operation type: "pow2", "sqrt", "abs"
     * @return result The result of the scientific calculation
     */
    function scientificFunction(int256 _operand, string memory _operation) 
        public 
        returns (int256 result) 
    {
        require(bytes(_operation).length > 0, "Operation cannot be empty");
        
        if (keccak256(abi.encodePacked(_operation)) == keccak256(abi.encodePacked("pow2"))) {
            result = _operand * _operand;
        } else if (keccak256(abi.encodePacked(_operation)) == keccak256(abi.encodePacked("sqrt"))) {
            require(_operand >= 0, "Cannot calculate square root of negative number");
            result = _sqrt(_operand);
        } else if (keccak256(abi.encodePacked(_operation)) == keccak256(abi.encodePacked("abs"))) {
            result = _operand < 0 ? -_operand : _operand;
        } else {
            revert("Invalid operation. Use: pow2, sqrt, abs");
        }
        
        // Store in history
        _storeCalculation(_operation, _operand, 0, result);
        
        emit ScientificCalculation(msg.sender, _operation, _operand, result);
        
        return result;
    }
    
    /**
     * @dev Returns the calculation history for the calling user
     * @return Array of Calculation structs representing user's history
     */
    function getMyHistory() public view returns (Calculation[] memory) {
        return userHistory[msg.sender];
    }
    
    /**
     * @dev Returns the number of calculations performed by the calling user
     * @return count Number of calculations in user's history
     */
    function getMyCalculationCount() public view returns (uint256 count) {
        return userHistory[msg.sender].length;
    }
    
    /**
     * @dev Clears the calculation history for the calling user
     */
    function clearMyHistory() public {
        delete userHistory[msg.sender];
    }
    
    /**
     * @dev Returns the latest calculation from user's history
     * @return Latest calculation struct or empty struct if no history
     */
    function getLatestCalculation() public view returns (Calculation memory) {
        Calculation[] memory history = userHistory[msg.sender];
        require(history.length > 0, "No calculation history found");
        return history[history.length - 1];
    }
    
    /**
     * @dev Internal function to store calculation in user's history
     * @param _operation The operation performed
     * @param _operand1 First operand
     * @param _operand2 Second operand (0 for scientific functions)
     * @param _result The calculation result
     */
    function _storeCalculation(string memory _operation, int256 _operand1, int256 _operand2, int256 _result) 
        internal 
    {
        userHistory[msg.sender].push(Calculation({
            operation: _operation,
            operand1: _operand1,
            operand2: _operand2,
            result: _result,
            timestamp: block.timestamp,
            user: msg.sender
        }));
        
        totalCalculations++;
    }
    
    /**
     * @dev Internal function to calculate square root using Babylonian method
     * @param _number The number to find square root of
     * @return Square root (approximated for integers)
     */
    function _sqrt(int256 _number) internal pure returns (int256) {
        if (_number == 0) return 0;
        
        int256 x = _number;
        int256 y = (_number + 1) / 2;
        
        while (y < x) {
            x = y;
            y = (_number / x + x) / 2;
        }
        
        return x;
    }
}
