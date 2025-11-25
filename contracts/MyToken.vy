# @version ^0.3.0
# @license MIT

event Transfer:
    owner: indexed(address) #from은 예약어
    to: indexed(address)
    amount: uint256

event Approval:
    # 원래는 owner: address 까지 적어주는 것 권장 (msg.sender로 사용할 수 있지만)
    spender: indexed(address)
    amount: uint256

#추가
owner: address
manager: address

name: public(String[64])
symbol: public(String[32])
decimals: public(uint256)
totalSupply: public(uint256)
#바이퍼만 스네이크 대신 낙타 사용..

balanceOf: public(HashMap[address, uint256])
allowances: public(HashMap[address, HashMap[address, uint256]])
 
@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint256, _initialSupply: uint256):
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.totalSupply = _initialSupply * 10 ** 18
    self.balanceOf[msg.sender] += _initialSupply * 10 ** 18
    #추가
    self.owner = msg.sender
    self.manager = msg.sender

# 함수 호출 시 함수 정의 순서 중요 
@internal
def onlyOwner(_owner: address):
    assert self.owner == _owner, "You are not authorized"
    
@internal
def onlyManager(_manager: address):
    assert self.manager == _manager, "You are not authorized to manage this contract"

  
@external
def transfer(_amount:uint256, _to:address):
    assert self.balanceOf[msg.sender] >= _amount, "insufficient balance" #require 역할
    self.balanceOf[msg.sender] -= _amount
    self.balanceOf[_to] += _amount
    #emit이던게 log로 변함
    log Transfer(msg.sender, _to, _amount)

@external
def approve( _spender:address, _amount:uint256):
    # assert self.balanceOf[_owner] >= _amount, "insuffient balance"
    self.allowances[msg.sender][_spender] += _amount

    log Approval(_spender, _amount)

@external
def transferFrom(_owner:address, _to:address, _amount:uint256):
    assert self.allowances[_owner][msg.sender] >= _amount, "insufficient allowance"
    assert self.balanceOf[_owner] >= _amount, "insufficient balance"
    self.balanceOf[_owner] -= _amount
    self.balanceOf[_to] += _amount
    self.allowances[_owner][msg.sender] -= _amount

    log Transfer(_owner, _to, _amount)

@internal
def _mint(_amount: uint256, _to: address):
    self.balanceOf[_to] += _amount
    self.totalSupply += _amount
    #zero address in solidity : address(0)
    log Transfer(ZERO_ADDRESS, _to, _amount)

@external
def mint(_amount: uint256, _to: address):
    self.onlyManager(msg.sender)
    self._mint(_amount, _to)


@external
def setManager(_manager: address):
    self.onlyOwner(msg.sender)
    self.manager = _manager
    