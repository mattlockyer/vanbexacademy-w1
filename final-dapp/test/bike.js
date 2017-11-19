

//jshint ignore: start

const Bike = artifacts.require('./Bike.sol');

contract('Bike', function(accounts) {
  
  let bikeshare;
  const owner = accounts[0];
  const random = accounts[1];
  
  it('should be deployed', async () => {
    bikeshare = await Bike.deployed();
    
    assert(bikeshare.address !== undefined, 'Bike was not deployed');
  });
  
  it('should be able purchase credits', async () => {
    const tx = await bikeshare.purchaseCredits({
      from: owner,
      value: web3.toWei(1, 'ether')
    });
    const credits = await bikeshare.credits(owner);
    
    assert(credits.toNumber() === 1000, 'Wrong amount of credits');
  });
  
  it('should be able to rent bike 2', async () => {
    const tx = await bikeshare.rentBike(2);
    const bikes = await bikeshare.getRented.call();
    
    assert(bikes[0].toNumber() === 2, 'Bike 2 not rentable');
  });
  
  it('should be able to ride bike 2', async () => {
    const tx = await bikeshare.rideBike(2, 25);
    const credits = await bikeshare.credits(owner);
    
    assert(credits.toNumber() === 875, 'Wrong amount of credits');
  });
  
  it('should be able to return bike 2 with 25kms', async () => {
    const tx = await bikeshare.returnBike(2);
    const bikes = await bikeshare.getRented.call();
    const kms = await bikeshare.kms.call(2);
    
    assert(bikes.length === 0, 'Bike 2 still rented');
    assert(kms.toNumber() === 25, 'Bike 2 incorrect kms');
  });
  
});
