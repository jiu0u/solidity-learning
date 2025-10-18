// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMyToken {
    // MyToken.sol에서 사용할 함수의 헤더 가져오기
    function transfer(uint256 amount, address to) external;
    function transferFrom(address from, address to, uint256 amount) external;
    
}



contract TinyBank {
    event Staked(address, uint256);

    IMyToken public stakingToken; 
    mapping(address => uint256) public staked; 
    uint256 public totalStaked; 

    

    constructor(IMyToken _stakingToken) { 
        stakingToken = _stakingToken;
    }


    function stake(uint256 _amount) external {
        require(_amount >= 0, "cannot stake 0 amount");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }
}