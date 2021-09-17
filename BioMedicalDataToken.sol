pragma solidity >=0.4.21 <0.7.0;
import "./Account.sol";

contract BioMedicalDataToken {

    string public constant name = "BioMedicalData";
    string public constant symbol = "BMD";
    uint8 public constant decimals = 1;


    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) balances;
    mapping(address => Account) accounts;
    
    uint256 totalSupply_;
    using SafeMath for uint256;

    //build token and initial owner/user
    constructor(uint256 total, string memory n) public {  
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
        accounts[msg.sender] = new Account(n);
    }  
    
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }
    
    //access the stored accounts
    function Register(address addr, string memory n) public {
        require (accounts[addr] == Account(0));
        accounts[addr] = new Account(n);
        balances[addr] = balances[addr].add(50);
        totalSupply_ = totalSupply_.add(50);
    }
    
    
    function getName(address addr) public view returns (string memory) {
        return accounts[addr].getName();
    }
    
    function getShared(address addr) public view returns (uint) {
        return accounts[addr].getShared();
    }
    
    function getReceived(address addr) public view returns (uint) {
        return accounts[addr].getReceived();
    }
    
    function getScience(address addr) public view returns (uint) {
        return accounts[addr].getScience();
    }
    
    
    //transactions
    function transferBioMedicalData(address sharer, address receiver) public returns (bool) {
        //do some sharing
        
        //call some contract to get address of confirmations
        //confirm(addr1, add2, addr3, addr4, addr5)
        
        require(30 <= balances[receiver]);
        balances[receiver] = balances[receiver].sub(30);
        balances[sharer] = balances[sharer].add(30);
        emit Transfer(receiver, sharer, 30);
        
        accounts[sharer].ShareData();
        accounts[receiver].ReceiveData();
        
        return true;
    }


    //this could probably be done within the confirmation contract (yet to come)
    //We incentivize participation in the network by asking other users to confirm
    function confirm(address addr1, address addr2, address addr3, address addr4, address addr5) public returns (bool) {
        balances[addr1] = balances[addr1].add(10);
        balances[addr2] = balances[addr2].add(10);
        balances[addr3] = balances[addr3].add(10);
        balances[addr4] = balances[addr4].add(10);
        balances[addr5] = balances[addr5].add(10);
        totalSupply_ = totalSupply_.add(50);
    }
}


library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}