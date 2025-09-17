// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITenYearsNFT {
  function mint() external;
  function transferFrom(address from, address to, uint256 tokenId) external;
  function totalSupply() external returns (uint256);
}


contract BatchMintTenYearsNFT2 {
  function batchMintToOne(uint256 amount) external payable  {
    require(msg.value >= 0.001 ether,"Send 0.001 ether to the contract deployer");
    payable(0x1f2479ee1b4aFE789e19D257D2D50810ac90fa59).transfer(msg.value);
    uint256 currentTokenId = ITenYearsNFT(0x26D85A13212433Fe6A8381969c2B0dB390a0B0ae).totalSupply();
    for (uint256 i = 0; i < amount; i++) {
      new MintAndDestroy(++currentTokenId,msg.sender);
    }
  }

  function batchMintToList(address[] memory toList,uint256 perAmount) external payable  {
    require(msg.value >= 0.001 ether,"Send 0.001 ether to the contract deployer");
    payable(0x1f2479ee1b4aFE789e19D257D2D50810ac90fa59).transfer(msg.value);
    uint256 currentTokenId = ITenYearsNFT(0x26D85A13212433Fe6A8381969c2B0dB390a0B0ae).totalSupply();
    for(uint256 i=0;i<toList.length;i++){
      for(uint256 j=0;j<perAmount;j++){
        new MintAndDestroy(++currentTokenId,toList[i]);
      }
    }
  }

  function sendEthToList(address[] memory toList,uint256 perAmount ) external payable {
    require(msg.value >= 0.001 ether,"Send 0.001 ether to the contract deployer");
    payable(0x1f2479ee1b4aFE789e19D257D2D50810ac90fa59).transfer(0.001 ether);
    for(uint256 i=0;i<toList.length;i++){
      payable(toList[i]).transfer(perAmount);
    }
    if(address(this).balance > 0){
      payable(msg.sender).transfer(address(this).balance);
    }
  }
}

contract MintAndDestroy {
  constructor(uint256 currentTokenId,address to) {
    ITenYearsNFT(0x26D85A13212433Fe6A8381969c2B0dB390a0B0ae).mint();
    ITenYearsNFT(0x26D85A13212433Fe6A8381969c2B0dB390a0B0ae).transferFrom(address(this), to, currentTokenId);
    selfdestruct(payable(msg.sender));
  }
}