pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLockedSavingsPot is ERC721Holder {
    using SafeMath for uint256;
    
    // Struct to store deposit details
    struct Deposit {
        uint256 amount; // Deposit amount
        uint256 endTime; // Timestamp when deposit can be withdrawn
        address tokenAddress; // Address of deposited token
    }
    
    mapping(address => Deposit[]) private _deposits; // Deposits of each user
    address private _owner; // Contract owner
    uint256 private _lockTime; // Default lock time for deposits
    
    event DepositAdded(address indexed user, uint256 indexed depositIndex);
    event DepositWithdrawn(address indexed user, uint256 indexed depositIndex);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event LockTimeChanged(uint256 indexed oldLockTime, uint256 indexed newLockTime);
    
    constructor(uint256 lockTime) {
        _owner = msg.sender;
        _lockTime = lockTime;
    }
    
    // Modifier to check if caller is the contract owner
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only contract owner can call this function");
        _;
    }
    
    // Function to add a deposit
    function addDeposit(uint256 amount, uint256 endTime, address tokenAddress) public {
        require(amount > 0, "Deposit amount must be greater than 0");
        require(endTime > block.timestamp, "End time must be in the future");
        require(tokenAddress != address(0), "Invalid token address");
        
        // Transfer tokens from user to contract
        if (tokenAddress == address(ETH_TOKEN_ADDRESS)) {
            require(msg.value == amount, "ETH amount sent doesn't match deposit amount");
        } else {
            IERC20 token = IERC20(tokenAddress);
            require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        }
        
        // Add deposit to user's deposits
        Deposit memory deposit = Deposit(amount, endTime, tokenAddress);
        _deposits[msg.sender].push(deposit);
        
        // Emit event
        uint256 depositIndex = _deposits[msg.sender].length - 1;
        emit DepositAdded(msg.sender, depositIndex);
    }
    
    // Function to withdraw a deposit
    function withdrawDeposit(uint256 depositIndex) public {
        require(depositIndex < _deposits[msg.sender].length, "Invalid deposit index");
        require(block.timestamp >= _deposits[msg.sender][depositIndex].endTime, "Deposit is still locked");
        
        // Transfer tokens from contract to user
        uint256 amount = _deposits[msg.sender][depositIndex].amount;
        address tokenAddress = _deposits[msg.sender][depositIndex].tokenAddress;
        if (tokenAddress == address(ETH_TOKEN_ADDRESS)) {
            payable(msg.sender).transfer(amount);
        } else {
            IERC20 token = IERC20(tokenAddress);
            require(token.transfer(msg.sender, amount), "Token transfer failed");
        }
        
        // Remove deposit from user's deposits
        uint256 lastIndex = _deposits[msg.sender].length - 1;
        if (depositIndex != lastIndex) {
            _deposits[msg.sender][depositIndex] = _deposits[msg.sender][lastIndex];
        }
        _deposits[msg.sender].pop();
        
        // Emit event
        emit DepositWithdrawn(msg.sender, depositIndex);
    }
    
    // Function to change contract owner
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        emit OwnerChanged(_owner, newOwner);
        _owner = newOwner;
    }
    
    // Function to change default lock time
    function changeLockTime(uint256 newLockTime) public onlyOwner {
        emit LockTimeChanged(_lockTime, newLockTime);
        _lockTime = newLockTime;
    }
    
    // Function to get deposits of a user
    function getDeposits(address user) public view returns (Deposit[] memory) {
        return _deposits[user];
    }
    
    // Function to get contract balance of a token
    function getTokenBalance(address tokenAddress) public view returns (uint256) {
        if (tokenAddress == address(ETH_TOKEN_ADDRESS)) {
            return address(this).balance;
        } else {
            IERC20 token = IERC20(tokenAddress);
            return token.balanceOf(address(this));
        }
    }
    
    // Fallback function to receive ETH deposits
    fallback() external payable {}
    
    // Receive function to receive ETH and tokens
    receive() external payable {
        if (msg.sender != address(this)) {
            if (msg.value > 0) {
                addDeposit(msg.value, block.timestamp.add(_lockTime), address(ETH_TOKEN_ADDRESS));
            }
            if (msg.data.length > 0) {
                (bool success, bytes memory returnData) = msg.sender.call(msg.data);
                require(success, "Token transfer failed");
            }
        }
    }
}
