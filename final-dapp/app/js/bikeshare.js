


const BikeShare = {
  
  contract: null,
  currentUser: null,
  block: null,
  /**************************************
  * initializing the contract
  **************************************/
  async init() {
    console.log('BikeShare initialized');
    //this.getWeb3(); //http://localhost:8545
    this.getWeb3('http://localhost:9545'); //truffle develop
    this.block = 0;
    //this.block = web3.eth.blockNumber(console.log);
    web3.eth.getAccounts((err, accounts) => {
      this.currentUser = accounts[0];
    });
    const json = await fetch('../../build/contracts/BikeShare.json').then((res) => res.json());
    this.contract = await this.getContract(json, '0xAC61aE2Bf10693c263Ac566093Cd2ffa67B0A0C9');
    this.setEventListeners();
  },
  /**************************************
  * event listeners
  **************************************/
  setEventListeners() {
    const { contract, block } = this;
    const event = contract.allEvents({ fromBlock: block, toBlock: 'latest' });
    event.watch((err, res) => {
      if (err) console.log('watch error', err);
      if (this[res.event] && typeof this[res.event] === 'function') this[res.event](res);
    });
  },
  //events
  async CreditsPurchased({ args }) {
    await App.refreshCredits();
    await App.refreshRental();
  },
  async BikeRented({ args }) {
    await App.refreshBikes();
    await App.refreshRental();
  },
  async BikeReturned({ args }) {
    await App.refreshBikes();
    await App.refreshRental();
  },
  async BikeRidden({ args }) {
    await App.refreshCredits();
    await App.refreshRental();
  },
  /**************************************
  * helpers
  **************************************/
  async getWeb3(fallbackURL = 'http://localhost:8545') { //using ganache-cli
    let web3;
    if (window.web3 !== undefined) {
      await new Web3(window.web3.currentProvider);
    } else {
      web3 = new Web3(new Web3.providers.HttpProvider(fallbackURL));
    }
  },
  async getContract(json, address, web3 = window.web3) {
    const contract = TruffleContract(json);
    contract.setProvider(web3.currentProvider);
    return address ? contract.at(address) : contract.deployed();
  }
};

