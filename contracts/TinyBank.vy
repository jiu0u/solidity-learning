# @version ^0.3.0
# @license MIT

#상수
INIT_REWARD: constant(uint256) = 1 * 10 ** 18 

MANAGER_NUMBERS : constant(int128) = 5



interface IMyToken:
    def transfer(_amount:uint256, _to:address): nonpayable
    def transferFrom(_owner:address, _to:address, _amount:uint256): nonpayable
    def mint(_amount:uint256, _to:address): nonpayable



event Staked:
    _owner: indexed(address)
    _amount: uint256

event Withdraw:
    _amount: uint256
    _to: indexed(address)



staked: public(HashMap[address, uint256])
totalStaked: public(uint256)

stakingToken:IMyToken

rewardPerBlock: uint256
lastClaimedBlock: HashMap[address, uint256]

owner: address
## manager: address
confirmed: bool[MANAGER_NUMBERS]
managers: address[MANAGER_NUMBERS]



@external
def __init__(_stakingToken:IMyToken, _managers: address[MANAGER_NUMBERS]):
    self.stakingToken = _stakingToken
    self.rewardPerBlock = INIT_REWARD 
    self.owner = msg.sender
    ## self.manager = msg.sender
    for i in range(MANAGER_NUMBERS):
        self.managers[i] = _managers[i]
    



############### modifier 기능 구현 ################

@internal
def onlyOwner(_owner: address):
    assert self.owner ==  _owner, "You are not authorized"

@internal
def isManager(_manager: address) -> bool:
    found : bool = False
    for i in range(MANAGER_NUMBERS):
        if(self.managers[i] == _manager):
            found = True
            break
    return found
    
    
@internal
def managerInfo(_manager: address) -> uint256:
    for i in range(MANAGER_NUMBERS):
        if(self.managers[i] == _manager):
            return i
    assert False, "You are not a managers" #return 되지 않았을 때만 실행
    return 0 #컴파일러용..
        

@external
def confirm():
    assert self.isManager(msg.sender), "You are not a managers"
    self.confirmed[self.managerInfo(msg.sender)] = True

@internal
def allConfirmed() -> bool:
    for i in range(MANAGER_NUMBERS):
        if not self.confirmed[i]:
            return False
    return True

@internal
def confirmReset():
    for i in range(MANAGER_NUMBERS):
        self.confirmed[i] = False

@internal
def onlyAllConfirmed(_sender: address):
    assert self.isManager(_sender), "You are not a managers"
    assert self.allConfirmed(), "Not all confirmed yet"
    self.confirmReset()

#Deprecated....(vyper에는 없음)
#@internal
#def onlyManager(_manager: address):
#    assert self.manager == _manager, "You are not authorized to manage this contract"

##################################

@external
def setRewardPerBlock(_amount: uint256):
    ##self.onlyManager(msg.sender)
    ##추가!
    self.onlyAllConfirmed(msg.sender)
    self.rewardPerBlock = _amount


@internal
def updateReward(_to: address):
    #staking 한 적이 있는 경우에만 실행
    if self.staked[_to] > 0:
        blocks: uint256 = block.number - self.lastClaimedBlock[_to]
        reward: uint256 = self.rewardPerBlock * blocks * self.staked[_to] / self.totalStaked
        self.stakingToken.mint(reward, _to)

    self.lastClaimedBlock[_to] = block.number



@external
def stake(_amount: uint256):
    assert _amount > 0, "cannot stake 0 amount"
    self.updateReward(msg.sender)
    self.stakingToken.transferFrom(msg.sender, self, _amount)
    self.staked[msg.sender] += _amount
    self.totalStaked += _amount
    log Staked(msg.sender, _amount)

@external
def withdraw(_amount: uint256):
    assert self.staked[msg.sender] >= _amount, "insufficient staked token"
    self.updateReward(msg.sender)
    self.stakingToken.transfer(_amount, msg.sender)
    self.staked[msg.sender] -= _amount
    self.totalStaked -= _amount
    log Withdraw(_amount, msg.sender)

    

    
