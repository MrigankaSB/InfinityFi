// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title InfinityFi
 * @dev A decentralized finance protocol for infinite financial possibilities
 */
contract Project {
    // State variables
    address public owner;
    uint256 public totalSupply;
    uint256 public stakingRewardRate;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakingTimestamp;
    mapping(address => uint256) public rewards;

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier hasBalance(uint256 amount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        _;
    }

    constructor() {
        owner = msg.sender;
        stakingRewardRate = 5; // 5% annual reward rate
        totalSupply = 0;
    }

    /**
     * @dev Deposit funds into the protocol
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        totalSupply += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Withdraw funds from the protocol
     * @param amount Amount to withdraw
     */
    function withdraw(uint256 amount) public hasBalance(amount) {
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    /**
     * @dev Stake tokens to earn rewards
     * @param amount Amount to stake
     */
    function stake(uint256 amount) public hasBalance(amount) {
        require(amount > 0, "Stake amount must be greater than 0");

        // Calculate pending rewards before updating stake
        if (stakedBalances[msg.sender] > 0) {
            updateRewards(msg.sender);
        }

        balances[msg.sender] -= amount;
        stakedBalances[msg.sender] += amount;
        stakingTimestamp[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Unstake tokens
     * @param amount Amount to unstake
     */
    function unstake(uint256 amount) public {
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        require(amount > 0, "Unstake amount must be greater than 0");

        updateRewards(msg.sender);

        stakedBalances[msg.sender] -= amount;
        balances[msg.sender] += amount;

        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev Update rewards for a user
     * @param user Address of the user
     */
    function updateRewards(address user) internal {
        uint256 stakingDuration = block.timestamp - stakingTimestamp[user];
        uint256 reward = (stakedBalances[user] * stakingRewardRate * stakingDuration) / (365 days * 100);
        rewards[user] += reward;
        stakingTimestamp[user] = block.timestamp;
    }

    /**
     * @dev Claim staking rewards
     */
    function claimRewards() public {
        if (stakedBalances[msg.sender] > 0) {
            updateRewards(msg.sender);
        }

        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to claim");

        rewards[msg.sender] = 0;
        balances[msg.sender] += reward;

        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @dev Get user's staking information
     * @param user Address of the user
     */
    function getStakingInfo(address user) public view returns (
        uint256 stakedAmount,
        uint256 pendingRewards,
        uint256 stakingTime
    ) {
        stakedAmount = stakedBalances[user];
        stakingTime = stakingTimestamp[user];

        if (stakedAmount > 0) {
            uint256 stakingDuration = block.timestamp - stakingTime;
            pendingRewards = rewards[user] + 
                (stakedAmount * stakingRewardRate * stakingDuration) / (365 days * 100);
        } else {
            pendingRewards = rewards[user];
        }

        return (stakedAmount, pendingRewards, stakingTime);
    }

    /**
     * @dev Update staking reward rate (owner only)
     * @param newRate New reward rate
     */
    function updateRewardRate(uint256 newRate) public onlyOwner {
        require(newRate <= 100, "Reward rate cannot exceed 100%");
        stakingRewardRate = newRate;
    }

    /**
     * @dev Transfer ownership
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    /**
     * @dev Get contract balance
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Receive function to accept ETH
     */
    receive() external payable {
        deposit();
    }
}

