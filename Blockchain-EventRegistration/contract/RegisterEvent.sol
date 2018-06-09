pragma solidity ^0.4.23;

contract SmartContractRegisterEvent {

    struct People {
        bytes16 name;
        bytes16 email;
        bytes16 phoneNumber;
        bool purchased;
    }

    //Precio Base
    uint256 public baseOneEther = 1 ether;

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

    //Evento para mostrar resultado de compra
    event resultRegister(
       bytes16 name,
       uint256 priceTicket
    );

    constructor (string _eventName) public {
        owner = msg.sender;
        eventName = _eventName;
    }
	
    //Registro
    function register(bytes16 _name, bytes16 _email, bytes16 _phoneNumber) payable public {
        //validar que no se hayan acabado los tickets
        require(ticketsSold <= ticketLimit,"Boletos agotados");
        // que el precio actual sea igual al valor enviado o si ya compro.
        require(msg.value == currentPrice() && attendants[msg.sender].purchased == false, "Ya haz comprado la entrada o saldo insuficiente");
        //Agregar registro
        addAttendantAndTransfer(_name, _email, _phoneNumber);
        //Notificar evento
        emit resultRegister(_name, msg.value);
    }

    //Agregar la persona al registro
    function addAttendantAndTransfer(bytes16 _name, bytes16 _email, bytes16 _phoneNumber) internal {
        attendants[msg.sender] = People({
            name: _name,
            email: _email,
            phoneNumber: _phoneNumber,
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