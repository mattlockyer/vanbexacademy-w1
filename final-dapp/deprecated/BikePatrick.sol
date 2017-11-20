

//jshint ignore: start

pragma solidity ^0.4.15;

import './Ownable.sol';

contract BikeShare is Ownable {
  
  //credit prices, onlyOwner
  uint256 creditPrice = 1 finney;
  uint256 creditPerKm = 5; //cost per km riding
  uint256 donationCredits = 500;
  
  // keeps track of user's credits
  mapping(address => uint256) public credits;
  
  /**************************************
  * bike inventory and state
  **************************************/
  Bike[] bikeInventory;
  struct Bike {
    address owner;
    address lastRenter;
    address currentRenter;
    uint256 kms;
    bool isRented;
  }
  
  /**************************************
  * events to log
  **************************************/
  event Donation(address _from, uint256 _amount, uint256 _time);
  event CreditsPurchased(address _to, uint256 _ethAmount, uint256 _creditAmount);
  event BikeRented(address _renter, uint256 _time);
  event BikeFreed(address _renter, uint8 _bikeNumber, uint256 _time);
  
  /**************************************
  * modifiers to restrict access and check conditions
  **************************************/
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
  * constructor, called when deployed
  **************************************/
  function BikeRental(uint256 _creditPrice, uint256 _creditPerKm, uint256 _donationCredits) {
    creditPerKm = _creditPerKm;
    creditPrice = _creditPrice;
    donationCredits = _donationCredits;
  }
  
  function setCreditPrice(uint256 _creditPrice) onlyOwner public { creditPrice = _creditPrice; }
  function setCreditPerKm(uint256 _creditPerKm) onlyOwner public { creditPerKm = _creditPerKm; }
  function setdonationCredits(uint256 _donationCredits) onlyOwner public { donationCredits = _donationCredits; }
  
  
  // Renting a bike cost 10 credits. If you
  function rentBike() public returns (bool) {
    // First check if he has enough credits
    require(credits[msg.sender] > 10);
  
    for (uint8 i = 0; i < bikeInventory.length; i++) {
      if (isBikeRented(i) == false) {
        bikeInventory[i].lastRenter = bikeInventory[i].currentRenter;
        bikeInventory[i].currentRenter = msg.sender;
        bikeInventory[i].isRented = true;
        credits[msg.sender] -= 10;
        BikeRented(msg.sender, now);
        return true;
      }
    }
    return false;
  }
  
  //earning credits by donating a bike, we can only have 5 bikes
  function donateBike() underBikeLimit external returns(uint256) {
    uint256 bikeNumber = bikeInventory.push(Bike({owner: msg.sender, lastRenter: 0x0, kms: 0, isRented: false, currentRenter: 0x0 }));
    credits[msg.sender] += donationCredits;
    Donation(msg.sender, donationCredits, now);
    return bikeNumber;
  }
  
  //Constant function
  // isBikeRented cannot be external as we call it in a function
  function isBikeRented(uint8 _index) public constant returns(bool) {
    return bikeInventory[_index].isRented;
  }
  
  function rideBike(uint8 _bikeNumber, uint256 _kms) onlyRenter(_bikeNumber) external returns(bool) {
    uint256 creditsRemaining = credits[msg.sender] - _kms * creditPerKm;
    if (creditsRemaining < 0) {
      return false;
    }
    bikeInventory[_bikeNumber].kms += _kms;
    credits[msg.sender] = creditsRemaining;
    return true;
  }
  
  function returnBike(uint8 _bikeNumber) external returns(bool success) {
    Bike storage currentEntry = bikeInventory[_bikeNumber];
    if (currentEntry.isRented == false || currentEntry.currentRenter != msg.sender) {
        revert();
    }
    currentEntry.isRented = false;
    success = true;
    BikeFreed(msg.sender, _bikeNumber, now);
  }

}


// // Iterable mapping https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol


// //jshint ignore: start

// pragma solidity ^0.4.15;

// import './Ownable.sol';

// contract Bike is Ownable {
  
//   /**************************************
//   * State
//   **************************************/
  
//   //bikes
//   Bike[] bikeInventory;
//   struct Bike {
//     address owner;
//     address lastRenter;
//     address currentRenter;
//     uint256 kms;
//     bool isRented;
//   }
//   //credits
// 	mapping(address => uint256) public credits;
//   //prices and rates
//   uint256 creditPrice = 1 finney;
// 	uint32 cpkm = 5; //cost per km riding
//   uint256 donateCredits = 500;
//   uint256 repairCredits = 250;
  
//   /**************************************
//   * Events
//   **************************************/
  
//   event Donation(address _from, uint256 _amount, uint256 _time);
//   event CreditsPurchased(address _to, uint256 _ethAmount, uint256 _creditAmount);
//   event BikeRented(address _renter, uint256 _time);
//   event BikeFreed(address _renter, uint8 _bikeNumber, uint256 _time);
  
//   /**************************************
//   * Modifiers
//   **************************************/
	
// 	modifier hasCredits(uint256 _kms) {
// 	  require(credits[msg.sender] - _kms * cpkm > 0);
//     _;
//   }
  
// 	modifier onlyRenter(uint32 _bike) {
//     require(lastRenter[_bike] == msg.sender);
//     _;
//   }
//   modifier onlyRenter(uint8 _bikeNumber) {
//     require(bikeInventory[_bikeNumber].currentRenter == msg.sender);
//     _;
//   }

//   modifier onlyBikeOwner(uint8 _bikeNumber) {
//     require(bikeInventory[_bikeNumber].owner == msg.sender);
//     _;
//   }

//   modifier underBikeLimit() {
//     require(bikeInventory.length < 5);
//     _;
//   }
	
// 	/**************************************
//   * Functions
//   **************************************/
	
// 	function Bike() {
// 	  //do we need this?
// 	  //should we set vars in contructor, is it better practice?
// 	}
	
// 	function setCreditPrice(uint256 _creditPrice) onlyOwner public { creditPrice = _creditPrice; }
// 	function setCPKM(uint32 _cpkm) onlyOwner public { cpkm = _cpkm; }
// 	function setDonateCredits(uint256 _donateCredits) onlyOwner public { donateCredits = _donateCredits; }
// 	function setRepairCredits(uint256 _repairCredits) onlyOwner public { repairCredits = _repairCredits; }
	
// 	//additional getters not provided by public
	
// 	function getRented() public returns (uint32[]) {
// 	  uint32[] memory list = new uint32[](bikesRented[msg.sender]);
// 	  uint32 index = 0;
// 	  for (uint32 i = 0; i < bikes; i++) {
// 	    if (rented[msg.sender][i]) {
// 	      list[index] = i;
// 	      index++;
// 	    }
// 	  }
// 	  return list;
// 	}
	
// 	//buying credits
	
// 	function purchaseCredits() payable {
// 	  uint256 amount = msg.value / creditPrice;
// 	  credits[msg.sender] += amount;
// 	}
	
// 	//earning credits
	
// 	function donateBike() {
// 	  bikes++;
// 	  credits[msg.sender] = donateCredits;
// 	}
	
// 	function repairBike() {
// 	  bikes++;
// 	  credits[msg.sender] = repairCredits;
// 	}
	
// 	//renting and riding bikes
	
	
	
// 	//functions
	
// 	function rentBike(uint32 _bike) {
// 	  lastRenter[_bike] = msg.sender;
// 	  rented[msg.sender][_bike] = true;
// 	  bikesRented[msg.sender]++;
// 	}
	
// 	function rideBike(uint32 _bike, uint32 _kms) onlyRenter(_bike) hasCredits(_kms) {
// 	  kms[_bike] += _kms;
// 	  credits[msg.sender] -= _kms * cpkm;
// 	}
	
// 	function returnBike(uint32 _bike) onlyRenter(_bike) {
// 	  lastRenter[_bike] = msg.sender;
// 	  delete rented[msg.sender][_bike];
// 	  bikesRented[msg.sender]--;
// 	}

// }



