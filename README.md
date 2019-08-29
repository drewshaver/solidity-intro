# solidity-intro

Slides location: https://docs.google.com/presentation/d/1C6LwNVnUlo4huhu24Hy_v5WACRb1caJ1leMw3GMhH8Q/edit?usp=sharing

IDE: https://remix.ethereum.org

Owned contract:

```
contract Owned {
    constructor() public { owner = msg.sender; }
    address payable owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _; /* jumps to code of function using this modifier */
    }
}
```
