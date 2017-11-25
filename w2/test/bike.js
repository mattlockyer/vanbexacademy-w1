

//jshint ignore: start

const BikeShare = artifacts.require('./BikeShare.sol');

contract('BikeShare', function(accounts) {
  
  let bikeshare;
  const owner = accounts[0];
  const random = accounts[1];
  
  it('should be deployed', async () => {
    bikeshare = await BikeShare.deployed();
    
    assert(bikeshare.address !== undefined, 'Bike was not deployed');
  });
  
  it('should be able purchase credits', async () => {
    const tx = await bikeshare.sendTransaction({
      from: owner,
      value: web3.toWei(1, 'ether')
    });
    const credits = await bikeshare.credits.call(owner);
    
    
    assert(credits.toNumber() === 1000, 'Wrong amount of credits');
  });
  
  it('should be able to rent bike 2', async () => {
    const tx = await bikeshare.rentBike(2);
    const bike = await bikeshare.bikeRented.call(owner);
    const available = await bikeshare.getAvailable.call();
    
    
    assert(bike.toNumber() === 2, 'Bike 2 not rentable');
    assert(available[2], 'Bike 2 not rentable');
  });
  
  it('should be able to ride bike 2', async () => {
    const tx = await bikeshare.rideBike(25);
    const credits = await bikeshare.credits(owner);
    
    assert(credits.toNumber() === 875, 'Wrong amount of credits');
  });
  
  it('should be able to return bike 2 with 25kms', async () => {
    const tx = await bikeshare.returnBike();
    const bike = await bikeshare.bikes.call(2);
    const available = await bikeshare.getAvailable.call();
    
    assert(bike[2].toNumber() === 25, 'Bike 2 incorrect kms');
    assert(!available[2], 'Bike 2 not rentable');
  });
  
});
