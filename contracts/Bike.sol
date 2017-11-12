

//jshint ignore: start

pragma solidity ^0.4.13;

import './Ownable.sol';

contract Bike is Ownable {
  
  //credits
  uint256 price;
	mapping(address => uint256) public credits;
  
	//bikes
	uint32 public bikes;
	mapping(uint32 => uint32) public kms;
	mapping(uint32 => address) public lastRenter;
	
	//renting and riding
	uint32 public cpkm;
	mapping(address => uint32) public bikesRented;
	mapping(address => mapping(uint32 => bool)) public rented;
	
	//constructor and getters
	
	function Bike() {
	  bikes = 5;
	  price = 1 finney;
	  cpkm = 5;
	}
	
	function getRented() public returns (uint32[]) {
	  uint32[] memory list = new uint32[](bikesRented[msg.sender]);
	  uint32 index = 0;
	  for (uint32 i = 0; i < bikes; i++) {
	    if (rented[msg.sender][i]) {
	      list[index] = i;
	      index++;
	    }
	  }
	  return list;
	}
	
	//buying credits
	
	function purchaseCredits() payable {
	  uint256 amount = msg.value / price;
	  credits[msg.sender] += amount;
	}
	
	//earning credits
	
	function donateBike() {
	  bikes++;
	  credits[msg.sender] = 1000;
	}
	
	function repairBike() {
	  bikes++;
	  credits[msg.sender] = 1000;
	}
	
	//renting and riding bikes
	
	function rentBike(uint32 _bike) {
	  lastRenter[_bike] = msg.sender;
	  rented[msg.sender][_bike] = true;
	  bikesRented[msg.sender]++;
	}
	
	function rideBike(uint32 _bike, uint32 _kms) {
	  //require(lastRenter[_bike] === msg.sender);
	  kms[_bike] += _kms;
	  credits[msg.sender] -= _kms * cpkm;
	}
	
	function returnBike(uint32 _bike) {
	  lastRenter[_bike] = msg.sender;
	  delete rented[msg.sender][_bike];
	  bikesRented[msg.sender]--;
	}

}
