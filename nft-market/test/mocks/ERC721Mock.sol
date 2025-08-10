// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {console} from "forge-std/console.sol";

contract ERC721Mock is ERC721 {
    constructor() ERC721("ERC721Mock", "E721M") {}

    function mint(address to, uint256 tokenId) public {
        console.log("mint", to, tokenId);
        _mint(to, tokenId);
    }
}


