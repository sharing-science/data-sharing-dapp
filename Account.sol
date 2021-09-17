pragma solidity >=0.4.21 <0.7.0;

contract Account {

        string user_name;
        address user;
        uint science_index = 0;
        uint data_shared = 0;
        uint data_received = 0;

    constructor(string memory name) public {
        user_name = name;
        user = msg.sender;
    }
    
    function getAddr() public view returns (address) {
        return user;
    }
    
    function getName() public view returns (string memory) {
        return user_name;
    }
    
    function getShared() public view returns (uint) {
        return data_shared;
    }
    
    function getReceived() public view returns (uint) {
        return data_received;
    }
    
    function getScience() public view returns (uint) {
        return science_index;
    }
    
    function ShareData() public {
        data_shared += 1;
        updateScience();
    }
    
    function ReceiveData() public {
        data_received += 1;
        updateScience;
    }
    
    function updateScience() public {
        science_index = data_shared * 3 - data_received;
    }
}


