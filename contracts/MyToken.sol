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

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _amount) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(_amount *10**uint256(decimals), msg.sender); // amount만큼 MT 발행
    }

    function _mint(uint256 amount, address owner) internal {
        totalSupply += amount;
        balanceOf[owner] += amount; 
    }

    function transfer(uint256 amount, address to) external {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");

        balanceOf[msg.sender] -= amount; 
        balanceOf[to] += amount; 
    }
 
}
