pragma solidity ^0.4.6;

contract Remittance {
    address     public owner;
    
    struct LockInfo {
        uint amount;
        address exchangeShop;
        bytes32 pw1pHash;
        uint deadline;
    }
    
    mapping(address => LockInfo) public lockInfos;
    
    function Remittance()
    {
        owner = msg.sender;
    }
    
    function registerLockInfo(address _exchangeShop, bytes32 _pw1Hash, uint deadlineDuration)
        public
        payable
        returns (bool)
    {
        if (msg.value == 0) throw;
        require(lockInfos[msg.sender].amount == 0);
        
        lockInfos[msg.sender].amount = msg.value;
        lockInfos[msg.sender].exchangeShop = _exchangeShop;
        lockInfos[msg.sender].pw1pHash = _pw1Hash;
        lockInfos[msg.sender].deadline = block.number + deadlineDuration;
        
        return true;
    }
    
    function unlockEther(bytes32 pw1, address payer)
        public
        payable
        returns (bool)
    {
        require(lockInfos[payer].amount > 0);
        require(msg.sender == lockInfos[payer].exchangeShop);
        require(keccak256(pw1) == lockInfos[payer].pw1Hash);

        uint amount = lockInfos[payer].amount;
        lockInfos[payer].amount = 0;
        msg.sender.transfer(amount);
        
        return true;
    }
    
    function refundExpiredRemittance () returns (bool) {
        require (lockInfos[msg.sender].amount > 0);
        require (lockInfos[msg.sender].deadline < block.number);
 
        uint amountToRefund = lockInfos[msg.sender].amount;
        lockInfos[msg.sender].amount = 0;
        msg.sender.transfer(amountToRefund);
        
        return true;
    }
    
}