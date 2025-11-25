// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./MultiManagedAccess.sol";

interface IMyToken {
    // MyToken.sol에서 사용할 함수의 헤더 가져오기
    function transfer(uint256 amount, address to) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function mint(uint256 amount, address owner) external;
}



contract TinyBank is MultiManagedAccess {
    event Staked(address indexed from, uint256 amount); //왜 이름은 사라진거지..?
    event Withdraw(uint256 amount, address indexed to); //나 여기 왜 indexed 없지

    IMyToken public stakingToken; 

    mapping(address => uint256) public lastClaimedBlock; //reawrd 기준점.
    
    uint256 defaultRewardPerBlock =  1*10 ** 18; //1MT
    uint256 rewardPerBlock;
    
    mapping(address => uint256) public staked; 
    uint256 public totalStaked; 

    

    constructor(IMyToken _stakingToken, address[MANAGER_NUMBERS] memory _managers) MultiManagedAccess(msg.sender, _managers) { 
        stakingToken = _stakingToken;
        rewardPerBlock = defaultRewardPerBlock;
    }

    function setRewardPerBlock(uint256 _amount) external onlyAllConfirmed {
        rewardPerBlock = _amount;
    }


    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount >= 0, "cannot stake 0 amount");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }


    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(staked[msg.sender] >= _amount, "insufficient staked token" );
        stakingToken.transfer(_amount, msg.sender);
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;
        emit Withdraw(_amount, msg.sender);
    }

    modifier updateReward(address to) {
        if (staked[to] > 0) {
        uint256 blocks = block.number - lastClaimedBlock[to];
        uint256 reward = (blocks * rewardPerBlock * staked[to]) / totalStaked ;
        stakingToken.mint(reward, to);
        }
        lastClaimedBlock[to] = block.number;
        _; //호출한 함수의 코드가 들어가는 위치 지정
    }

}