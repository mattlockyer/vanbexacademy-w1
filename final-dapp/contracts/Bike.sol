

//jshint ignore: start

pragma solidity ^0.4.13;

import './Ownable.sol';

contract Bike is Ownable {
  
  //credit prices, onlyOwner
  uint256 creditPrice = 1 finney;
	uint32 cpkm = 5; //cost per km riding
  uint256 donateCredits = 500;
  uint256 repairCredits = 250;
  
  //credits
	mapping(address => uint256) public credits;
  
	//bikes
	uint32 public bikes = 5;
	mapping(uint32 => uint32) public kms;
	mapping(uint32 => address) public lastRenter;
	
	//renting and riding
	mapping(address => uint32) public bikesRented;
	mapping(address => mapping(uint32 => bool)) public rented;
	
	//constructor and getters
	
	function Bike() {
	  //do we need this?
	  //should we set vars in contructor, is it better practice?
	}
	
	function setCreditPrice(uint256 _creditPrice) onlyOwner { creditPrice = _creditPrice; }
	function setCPKM(uint32 _cpkm) onlyOwner { cpkm = _cpkm; }
	function setDonateCredits(uint256 _donateCredits) onlyOwner { donateCredits = _donateCredits; }
	function setRepairCredits(uint256 _repairCredits) onlyOwner { repairCredits = _repairCredits; }
	
	//additional getters not provided by public
	
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
	  uint256 amount = msg.value / creditPrice;
	  credits[msg.sender] += amount;
	}
	
	//earning credits
	
	function donateBike() {
	  bikes++;
	  credits[msg.sender] = donateCredits;
	}
	
	function repairBike() {
	  bikes++;
	  credits[msg.sender] = repairCredits;
	}
	
	//renting and riding bikes
	
	//modifiers
	
	modifier hasCredits(uint256 _kms) {
	  require(credits[msg.sender] - _kms * cpkm > 0);
    _;
  }
  
	modifier onlyRenter(uint32 _bike) {
    require(lastRenter[_bike] == msg.sender);
    _;
  }
	
	//functions
	
	function rentBike(uint32 _bike) {
	  lastRenter[_bike] = msg.sender;
	  rented[msg.sender][_bike] = true;
	  bikesRented[msg.sender]++;
	}
	
	function rideBike(uint32 _bike, uint32 _kms) onlyRenter(_bike) hasCredits(_kms) {
	  kms[_bike] += _kms;
	  credits[msg.sender] -= _kms * cpkm;
	}
	
	function returnBike(uint32 _bike) onlyRenter(_bike) {
	  lastRenter[_bike] = msg.sender;
	  delete rented[msg.sender][_bike];
	  bikesRented[msg.sender]--;
	}

}
