# solidity-intro

Slides location: https://docs.google.com/presentation/d/1C6LwNVnUlo4huhu24Hy_v5WACRb1caJ1leMw3GMhH8Q/edit?usp=sharing

IDE: https://remix.ethereum.org

Owned contract:

```
pragma solidity ^0.5.11;

contract Owned {
    constructor() public { owner = msg.sender; }
    address payable owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _; /* jumps to code of function using this modifier */
    }
}


address buyer;
uint quantity; /* 100 */
uint price; /* 1000000000000000000 (1 ether) */
uint expiry; /* 1577836111 (New Years) */
Token token;

```
MIT license. This code is not suitable for any purposes except demonstration/educational.
