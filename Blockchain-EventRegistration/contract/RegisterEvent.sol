pragma solidity ^0.4.23;

contract SmartContractRegisterEvent {

    struct People {
        string name;
        string email;
        string phoneNumber,
        bool purchased;
    }

    //Precio Base
    uint256 basePrice = 0.05 ether;

    //Incrementar precio por fases
    uint256 priceIncrease = 0.0002 ether;

    //Precio maximo
    uint256 maxPrice = 0.07 ether;

    //Numero de Tickets
    uint256 ticketLimit = 100;

    //Boletos vendidos
    uint256 public ticketsSold;

    //Address del dueño
    address owner;

    //Nombre del evento
    string public eventName;

    //Mapeo del struct
    mapping(address => People) public attendants;   
    address[] allAttendants;

    constructor (string _eventName) public {
        owner = msg.sender;
        eventName = _eventName;
    }
	
    //Registro
    function register(string _name, string _email) payable public {

        require (msg.value == currentPrice() && attendants[msg.sender].purchased == false && ticketsSold <= ticketLimit,"Error de registro");

        addAttendantAndTransfer(_name,_email);
    }

    //Agregar la persona al registro
    function addAttendantAndTransfer(string _name, string _email) internal {
        attendants[msg.sender] = People({
            name: _name,
            email: _email,
            purchased: true
        });
        
        allAttendants.push(msg.sender);

        ticketsSold++;
        owner.transfer(address(this).balance);
    }

    // Devolver todos los asistentes
    function listAllAttendants() external view returns(address[]){
        return allAttendants;
    }

    //Ya compraste Ticket?
    function hasPurchased() public view returns (bool) {
        return attendants[msg.sender].purchased;
    }

    //Precio Actual
    function currentPrice() public view returns (uint256) {
        if(basePrice + (ticketsSold * priceIncrease) >= maxPrice) {
            return maxPrice;
        } else {
            return basePrice + (ticketsSold * priceIncrease);
        }
    }

    //Unicamente el owner
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

}