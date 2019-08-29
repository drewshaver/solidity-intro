pragma solidity ^0.5.11;

contract Owned {
    constructor() public { owner = msg.sender; }
    address payable owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _; /* jumps to code of function using this modifier */
    }
}

contract Token is Owned {
    mapping(address => uint) public balanceOf;
    
    constructor() Owned() public {}

    function issue(address recipient, uint amount) public onlyOwner {
        balanceOf[recipient] += amount;
    }

    function transfer(address recipient, uint amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
    }
}

contract CallOption is Owned {
    address buyer;
    uint quantity; /* 100 */
    uint price; /* 1000000000000000000 (1 ether) */
    uint expiry; /* 1577836111 (New Years) */
    Token token;

    constructor(address _buyer, uint _quantity, uint _price, uint _expiry, address _tokenAddress) Owned() public {
        buyer = _buyer;
        quantity = _quantity;
        price = _price;
        expiry = _expiry;
        token = Token(_tokenAddress);
    }

    /* first check that this contract is valid, then transfer out and clean up */
    function execute() public payable {
        require(msg.sender == buyer, "Unauthorized");        
        require(token.balanceOf(address(this)) == quantity, "Funding error");
        require(msg.value == price, "Payment error");
        require(now < expiry, "Expired");
        
        /* consider alternatives */
        token.transfer(buyer, quantity);
        selfdestruct(owner);
    }
    
    function refund() public {
        require(now > expiry, "Not expired");
        token.transfer(owner, quantity);
        selfdestruct(owner);
    }
}

contract CallOptionSeller is Owned {
    address buyer;
    uint quantity; /* 100 */
    uint strikePrice; /* 1000000000000000000 (1 ether) */
    uint purchasePrice; /* 100000000000000000 (0.1 ether) */
    uint expiry; /* 1577836111 (New Years) */
    bool wasPurchased; /* refactor as expression (buyer == 0x0)? */
    Token token;

    constructor(uint _quantity, uint _strikePrice, uint _purchasePrice, uint _expiry, address _tokenAddress) Owned() public {
        quantity = _quantity;
        strikePrice = _strikePrice;
        purchasePrice = _purchasePrice;
        expiry = _expiry;
        token = Token(_tokenAddress);
        wasPurchased = false; /* added for clarity, false is default value */
    }

    function purchase() public payable {
        require(!wasPurchased, "Option already purchased");
        require(msg.value == purchasePrice, "Incorrect purchase price");
        buyer = msg.sender;
        wasPurchased = true;
    }

    /* first check that this contract is valid, then transfer out and clean up */
    function execute() public payable {
        require(wasPurchased, "Option unpurchased");
        require(msg.sender == buyer, "Unauthorized");        
        require(token.balanceOf(address(this)) == quantity, "Funding error");
        require(msg.value == strikePrice, "Payment error");
        require(now < expiry, "Expired");
        
        /* consider alternatives */
        token.transfer(buyer, quantity);
        selfdestruct(owner);
    }
    
    function refund() public {
        if(wasPurchased) {
            require(now > expiry, "Not expired");
        }
        token.transfer(owner, quantity);
        selfdestruct(owner);
    }
}
