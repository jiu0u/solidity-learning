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
    }

    // external : 외부 호출만 가능하다 (public이랑 좀 다름)
    // returns : 리턴 '타입' 지정. 여러 개 반환 가능해서 -s가 붙음 (<-> return)
   
}
