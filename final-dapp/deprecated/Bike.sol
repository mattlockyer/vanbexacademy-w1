

//jshint ignore: start

pragma solidity ^0.4.15;

import './Ownable.sol';

contract Bike is Ownable {
  
  /**************************************
  * State
  **************************************/
  Bike[] bikeInventory;
  struct Bike {
    address owner;
    address lastRenter;
    address currentRenter;
    uint256 kms;
    bool isRented;
  }
  //credits
	mapping(address => uint256) public credits;
  //prices and rates
  uint256 creditPrice = 1 finney;
	uint32 cpkm = 5; //cost per km riding
  uint256 donateCredits = 500;
  uint256 repairCredits = 250;
  
  /**************************************
  * Events
  **************************************/
  event Donation(address _from, uint256 _amount, uint256 _time);
  event CreditsPurchased(address _to, uint256 _ethAmount, uint256 _creditAmount);
  event BikeRented(address _renter, uint256 _time);
  event BikeFreed(address _renter, uint8 _bikeNumber, uint256 _time);
  
  /**************************************
  * Modifiers
  **************************************/
	modifier hasCredits(uint256 _kms) {
	  require(credits[msg.sender] - _kms * cpkm > 0);
    _;
  }
	modifier onlyRenter(uint32 _bike) {
    require(lastRenter[_bike] == msg.sender);
    _;
  }
  modifier onlyRenter(uint8 _bikeNumber) {
    require(bikeInventory[_bikeNumber].currentRenter == msg.sender);
    _;
  }
  modifier onlyBikeOwner(uint8 _bikeNumber) {
    require(bikeInventory[_bikeNumber].owner == msg.sender);
    _;
  }
  modifier underBikeLimit() {
    require(bikeInventory.length < 5);
    _;
  }
	
	/**************************************
  * Functions
  **************************************/
	function Bike() {
	  //do we need this?
	  //should we set vars in contructor, is it better practice?
	}
	
	/**************************************
  * setters for bikeshare owner
  **************************************/
	function setCreditPrice(uint256 _creditPrice) onlyOwner public { creditPrice = _creditPrice; }
	function setCPKM(uint32 _cpkm) onlyOwner public { cpkm = _cpkm; }
	function setDonateCredits(uint256 _donateCredits) onlyOwner public { donateCredits = _donateCredits; }
	function setRepairCredits(uint256 _repairCredits) onlyOwner public { repairCredits = _repairCredits; }
	
	/**************************************
  * getters not provided by compiler
  **************************************/
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
	
	/**************************************
  * default payable function to purchase credits
  **************************************/
  function() payable {
    purchaseCredits();
  }
  //buying credits using ETH
  // Note the "internal"
  function purchaseCredits() internal {
    uint256 amount = msg.value / creditPrice; // flooring division
    CreditsPurchased(msg.sender, msg.value, amount);
    credits[msg.sender] += amount;
  }
  
  /**************************************
  * donating bicycles
  **************************************/
	function donateBike() {
	  bikes++;
	  credits[msg.sender] = donateCredits;
	}
	
	/**************************************
  * bike functions
  **************************************/
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