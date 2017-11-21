

//jshint ignore: start

pragma solidity ^0.4.15;

import './Ownable.sol';

contract BikeShare is Ownable {
  
  /**************************************
  * State
  **************************************/
  Bike[] public bikes;
  struct Bike {
    address owner;
    bool isRented;
    uint32 kms;
  }
  //credits
	mapping(address => uint32) public bikeRented;
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
  event BikeRented(address _renter, uint32 _bikeNumber, uint256 _time);
  event BikeRode(address _renter, uint32 _bikeNumber, uint32 _kms, uint256 _time);
  event BikeReturned(address _renter, uint32 _bikeNumber, uint256 _time);
	
	/**************************************
  * constructor
  **************************************/
	function BikeShare() {
	  //init with 5 bikes from the bikeshare owner
	  //we never rent bike 0, so we'll initialize 6 bikes
	  for (uint32 i = 0; i < 6; i++) {
	    bikes.push(Bike({ owner: msg.sender, isRented: false, kms: 0 }));
	  }
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
	function getAvailable() public constant returns (bool[]) {
	  bool[] memory available = new bool[](bikes.length);
	  //loop begins at index 1, never rent bike 0
	  for (uint32 i = 1; i < bikes.length; i++) {
	    if (bikes[i].isRented) {
	      available[i] = true;
	    }
	  }
	  return available;
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
	  credits[msg.sender] = donateCredits;
	  Donation(msg.sender, donateCredits, now);
	}
	
  /**************************************
  * Modifiers
  **************************************/
  modifier onlyBikeOwner(uint32 _bikeNumber) {
    require(bikes[_bikeNumber].owner == msg.sender);
    _;
  }
  modifier canRent(uint32 _bikeNumber) {
    //user isn't currently renting a bike && bike is available
    require(bikeRented[msg.sender] == 0 && !bikes[_bikeNumber].isRented);
    _;
  }
  modifier hasRental() {
    require(bikeRented[msg.sender] != 0);
    _;
  }
	modifier hasCredits(uint256 _kms) {
	  require(credits[msg.sender] - _kms * cpkm > 0);
    _;
  }
  
	/**************************************
  * bike functions
  **************************************/
	function rentBike(uint32 _bikeNumber) canRent(_bikeNumber) {
	  bikeRented[msg.sender] = _bikeNumber;
	  bikes[_bikeNumber].isRented = true;
	  BikeRented(msg.sender, _bikeNumber, now);
	}
	
	function rideBike(uint32 _kms) hasRental hasCredits(_kms) {
	  bikes[bikeRented[msg.sender]].kms += _kms;
	  credits[msg.sender] -= _kms * cpkm;
	  BikeRode(msg.sender, bikeRented[msg.sender], _kms, now);
	}
	
	function returnBike() hasRental {
	  bikes[bikeRented[msg.sender]].isRented = false;
	  bikeRented[msg.sender] = 0;
	  BikeReturned(msg.sender, bikeRented[msg.sender], now);
	}

}