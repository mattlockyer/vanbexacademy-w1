

//jshint ignore: start

const Bike = artifacts.require('./Bike.sol');

contract('Bike', function(accounts) {
  
  let bike;
  const owner = accounts[0];
  const random = accounts[1];
  
  it('should be deployed', async () => {
    bike = await Bike.deployed();
    
    assert(bike.address !== undefined, 'Bike was not deployed');
  });
  
  it('should be able purchase credits', async () => {
    const tx = await bike.purchaseCredits({
      from: owner,
      value: web3.toWei(1, 'ether')
    });
    const credits = await bike.credits(owner);
    
    assert(credits.toNumber() === 1000, 'Wrong amount of credits');
  });
  
  it('should be able to rent bike 2', async () => {
    const tx = await bike.rentBike(2);
    const bikes = await bike.getRented.call();
    
    assert(bikes[0].toNumber() === 2, 'Bike 2 not rentable');
  });
  
  it('should be able to ride bike 2', async () => {
    const tx = await bike.rideBike(2, 25);
    const credits = await bike.credits(owner);
    
    assert(credits.toNumber() === 875, 'Wrong amount of credits');
  });
  
  it('should be able to return bike 2 with 25kms', async () => {
    const tx = await bike.returnBike(2);
    const bikes = await bike.getRented.call();
    const kms = await bike.kms.call(2);
    
    assert(bikes.length === 0, 'Bike 2 still rented');
    assert(kms.toNumber() === 25, 'Bike 2 incorrect kms');
  });
  
});
