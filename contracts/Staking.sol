//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Token {
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function mint(address user, uint amount) external;
    function burn(address user, uint amount) external;
}


contract Staking {
    address public owner;
    address private lpTokenAddress;
    address private rewardTokenAddress;
    uint32 public timePeriod; //seconds

    struct Staked {
        uint256 amount;
        uint256 reward;
        uint256 timeStamp;
    }
    mapping(address => Staked) public stakeholders;

    modifier ownerOnly() {
        require(msg.sender == owner, "You are not owner");
        _;
    }

    constructor(address _lpTokenAddress, address _rewardTokenAddress) {
        owner = msg.sender;
        lpTokenAddress = _lpTokenAddress;
        rewardTokenAddress = _rewardTokenAddress;
        timePeriod = 600;
    }

    function stake(uint256 amount) public {
        require(ERC20Token(lpTokenAddress).allowance(msg.sender, address(this)) >= amount, "No enough allowance");
        refreshReward(msg.sender);
        ERC20Token(lpTokenAddress).transferFrom(msg.sender, address(this), amount);
        stakeholders[msg.sender].amount += amount;
    }
    
    function claim() public {
        require(block.timestamp - stakeholders[msg.sender].timeStamp >= timePeriod, "Time not passed");
        refreshReward(msg.sender);
        ERC20Token(rewardTokenAddress).transfer(msg.sender, stakeholders[msg.sender].reward);
        stakeholders[msg.sender].reward = 0;
    }

    function unstake(uint256 amount) public {
        require(stakeholders[msg.sender].amount != 0, "Zero balance staked");
        require(stakeholders[msg.sender].amount >= amount, "Not enough balance staked");
        refreshReward(msg.sender);
        ERC20Token(lpTokenAddress).transfer(msg.sender, amount);
        stakeholders[msg.sender].amount -= amount;
    }

    function refreshReward(address user) internal {
        stakeholders[user].reward += (block.timestamp - stakeholders[user].timeStamp) / timePeriod * stakeholders[user].amount * 20 / 100;
        stakeholders[msg.sender].timeStamp = block.timestamp;
    }

    function setTimePeriod(uint32 newTimePeriod) public ownerOnly {
        timePeriod = newTimePeriod;
    }
}
