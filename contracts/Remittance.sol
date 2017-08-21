pragma solidity ^0.4.6;

contract Remittance {
    address     public owner;
    
    struct LockInfo {
        uint amount;
        bytes32 pw1pw2Hash;
        uint deadline;
    }
    
    mapping(address => LockInfo) public lockInfos;
    
    function Remittance()
    {
        owner = msg.sender;
    }
    
    function registerLockInfo(bytes32 _pw1Hash, bytes32 _pw2Hash, uint deadlineDuration)
        public
        payable
        returns (bool)
    {
        if (msg.value == 0) throw;
        require(lockInfos[msg.sender].amount == 0);
        
        lockInfos[msg.sender].pw1pw2Hash = keccak256(_pw1Hash, _pw2Hash);
        lockInfos[msg.sender].amount = msg.value;
        lockInfos[msg.sender].deadline = block.number + deadlineDuration;
        
        return true;
    }
    
    function unlockEther(bytes32 _pw1Hash, bytes32 _pw2Hash, address payer)
        public
        payable
        returns (bool)
    {
        require(lockInfos[payer].amount > 0);
        bytes32 combinedHash = keccak256(_pw1Hash, _pw2Hash);

        require(lockInfos[payer].pw1pw2Hash == combinedHash);

        if (!msg.sender.send(lockInfos[payer].amount)) throw;
        lockInfos[payer].amount = 0;
        
        return true;
    }
    
    function refundExpiredRemittance () returns (bool) {
        require (lockInfos[msg.sender].amount > 0);
        require (lockInfos[msg.sender].deadline < block.number);
 
        uint amountToRefund = lockInfos[msg.sender].amount;
        
        msg.sender.transfer(amountToRefund);
        lockInfos[msg.sender].amount = 0;
        
        return true;
    }
    
    function getHash(string pw) public constant returns(bytes32) {
        return keccak256(pw);
    }
    
    
}