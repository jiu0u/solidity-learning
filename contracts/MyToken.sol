// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    //토큰의 총 발행 개수
    uint256 public totalSupply;

    //누가 얼마나 가지고 있는지
    mapping(address => uint256) public balanceOf;
    // (key => value)

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(1*10**uint256(decimals), msg.sender); // 1MT
        //uint256이 기본 (32바이트) <- decimals는 uint8타입 (변경필요)
    }

    //블록체인에서는 토큰을 발행할 때 minting, mint라는 단어를 사용함.
    function _mint(uint256 amount, address owner) internal {
        totalSupply += amount;
        balanceOf[owner] += amount; 
        // 가진 사람이 없으면 증발되니까..
    }
 
}
