pragma solidity ^0.4.23;

contract SmartContractRegisterEvent {

    struct Person {
        string name;
        string email;
        bool attendsInPerson;
        bool purchased;
    }

    //Precio Base
    uint256 basePrice = 0.05 ether;
    //Incrementar precio por fases
    uint256 priceIncrease = 0.00002 ether;
    //Precio maximo
    uint256 maxPrice = 0.07 ether;
    //Numero de Tickets
    uint256 faceToFaceLimit = 100;
    
    uint256 public ticketsSold;
    uint256 public ticketsFaceToFaceSold;

    address owner;

    string public eventName;

    mapping(address=>Person) public attendants;
   
    address[] allAttendants;
    address[] faceToFaceAttendants;

    constructor (string _eventName) public {
        owner = msg.sender;
        eventName = _eventName;
    }
	

    function register(string _name, string _email, bool _attendsInPerson) payable public {

        require (msg.value == currentPrice() && attendants[msg.sender].purchased == false);

        if(_attendsInPerson == true ) {
            ticketsFaceToFaceSold++;
            require (ticketsFaceToFaceSold <= faceToFaceLimit);

            addAttendantAndTransfer(_name, _email, _attendsInPerson);
            faceToFaceAttendants.push(msg.sender);
        } else {
            addAttendantAndTransfer(_name, _email, _attendsInPerson);
        }
        allAttendants.push(msg.sender);
    }

    function addAttendantAndTransfer(string _name, string _email, bool _attendsInPerson) internal {
        attendants[msg.sender] = Person({
            name: _name,
            email: _email,
            attendsInPerson: _attendsInPerson,
            purchased: true
        });
        ticketsSold++;
        owner.transfer(this.balance);
    }

    function listAllAttendants() external view returns(address[]){
        return allAttendants;
    }

    function listFaceToFaceAttendants() external view returns(address[]){
        return faceToFaceAttendants;
    }

    function hasPurchased() public view returns (bool) {
        return attendants[msg.sender].purchased;
    }

    function currentPrice() public view returns (uint256) {
        if(basePrice + (ticketsSold * priceIncrease) >= maxPrice) {
            return maxPrice;
        } else {
            return basePrice + (ticketsSold * priceIncrease);
        }
    }

    modifier onlyOwner() {
        if(owner != msg.sender) {
            revert();
        } else {
            _;
        }
    }

}