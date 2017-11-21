

const APP = {
  
  credits: 0,
  kms: 0,
  
  async init() {
    console.log('initialized');
    await BikeShare.init();
    console.log('bikeshare contract initialized');
    //get credits
    await this.refreshCredits();
    await this.refreshBikes();
    //set listeners
    this.setListeners();
  },
  async refreshCredits() {
    const { contract, currentUser } = BikeShare;
    this.credits = (await contract.credits.call(currentUser)).toNumber();
    qs('#creditBalance').innerHTML = this.credits;
  },
  async refreshBikes() {
    const { credits } = this;
    console.log(credits);
    const { contract, currentUser } = BikeShare;
    const bikes = (await contract.getAvailable.call()); //gets the bike array [false, true, false, ...]
    //map the bike indexes if they're available (false), filter, slice first index then join array
    qs('#bikesAvailable').innerHTML = bikes.map((v, i) => !v ? i : false).filter(v => v !== false).slice(1).join(', ');
    const bikeRented = (await contract.bikeRented.call(currentUser)).toNumber();
    qs('#bikeRented').innerHTML = bikeRented === 0 ? 'none' : bikeRented;
    qs('#rentBike').disabled = bikeRented;
    qs('#rideBike').disabled = !bikeRented || !credits;
    //get bike total kms
    qs('#rentalKMs').innerHTML = bikeRented === 0 ? 'n/a' : this.kms + ' km';
    qs('#totalKMs').innerHTML = bikeRented === 0 ? 'n/a' : (await contract.bikes.call(bikeRented))[2].toNumber() + ' km';
  },
  /**************************************
  * contract functions
  **************************************/
  setListeners() {
    //puchaseCredits
    qs('#purchaseCredits').onclick = async () => {
      const { contract, currentUser } = BikeShare;
      const input = qs('#purchaseInput');
      const { value } = input;
      if (value === '' || value === 0) {
        alert('please input some value of ETH');
        return;
      }
      input.value = '';
      const tx = await contract.sendTransaction({
        from: currentUser,
        value: web3.toWei(value, 'ether')
      });
    }
    //rentBike
    qs('#rentBike').onclick = async () => {
      const { contract, currentUser } = BikeShare;
      const input = qs('#bikeSelection');
      const bikeNumber = parseInt(input.value);
      input.value = '';
      const tx = await contract.rentBike(bikeNumber, { from: currentUser });
    }
    //returnBike
    qs('#returnBike').onclick = async () => {
      const { contract, currentUser } = BikeShare;
      const tx = await contract.returnBike({ from: currentUser });
      this.kms = 0;
    }
    //rideBike
    qs('#rideBike').onclick = async () => {
      const { contract, currentUser } = BikeShare;
      const input = qs('#kmSelection');
      const kms = parseInt(input.value);
      console.log(kms);
      if (!kms || kms === '' || kms === 0) {
        alert('please input a distance in kilometers');
        return;
      }
      input.value = '';
      const tx = await contract.rideBike(kms, { from: currentUser });
      this.kms += kms;
    }
  }
};

const qs = (sel) => document.querySelector(sel);

window.onload = () => APP.init();
