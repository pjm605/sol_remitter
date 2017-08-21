pragma solidity ^0.4.6;

contract Remittance {
    address     public owner;
    
    struct LockInfo {
        uint amount;
        bytes32 pw1pw2Hash;
    }
    
    mapping(address => LockInfo) public lockInfos;
    
    function Remittance()
    {
        owner = msg.sender;
    }
    
    function registerLockInfo(bytes32 _pw1Hash, bytes32 _pw2Hash)
        public
        payable
        returns (bool)
    {
        if (msg.value == 0) throw;
        require(lockInfos[msg.sender].amount == 0);
        
        lockInfos[msg.sender].pw1pw2Hash = keccak256(_pw1Hash, _pw2Hash);
        lockInfos[msg.sender].amount = msg.value;
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
        
        if (!msg.sender.send(lockInfos[payer].amount)) {
            // todo handle error in this case
        }
        else {
            // clear the amount (reset)
            lockInfos[payer].amount = 0;
        }
        return true;
    }
    
    function getHash(string pw) public constant returns(bytes32) {
        return keccak256(pw);
        
        
    }
    
    
}