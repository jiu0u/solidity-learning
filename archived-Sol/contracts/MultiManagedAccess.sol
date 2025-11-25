// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract MultiManagedAccess {
    uint constant MANAGER_NUMBERS = 5;

    address public owner;
    address[MANAGER_NUMBERS] public managers;
    bool[MANAGER_NUMBERS] public confirmed;

    constructor(address _owner, address[MANAGER_NUMBERS] memory _managers) {
        owner = _owner;
        for(uint i=0; i<MANAGER_NUMBERS; i++) {
            managers[i] = _managers[i];
        }
    } //deep copy

    modifier onlyOwner {
        require(msg.sender == owner, "You are not authorized");
        _;
    }


    function allConfirmed() internal view returns(bool) {
        for(uint i=0; i<MANAGER_NUMBERS; i++) {
            if(!confirmed[i]){
                return false;
            }
        }
        return true;
    }

    function reset() internal {
        for(uint i=0; i<MANAGER_NUMBERS; i++) {
            confirmed[i] = false;
        }
    }

    modifier onlyAllConfirmed 
    {
        //매니저가 호출했는지 확인
        bool isManager = false;
        for(uint i=0; i<MANAGER_NUMBERS; i++) {
            if(managers[i] == msg.sender) {
                isManager = true;
                break;
            }
            require(isManager, "You are not a managers");
        }
        // 모든 매니저가 동의했는지 확인
        require(allConfirmed(),"Not all confirmed yet");
        // confirm 기록 초기화
        reset();
        _;
    }
    

    function confirm() external {
        bool found = false;
        for(uint i=0; i<MANAGER_NUMBERS; i++) {
            if(managers[i] == msg.sender) {
                found = true;
                confirmed[i] = true;
                break;
            }
        }
        require(found, "You are not a managers");
    }
}