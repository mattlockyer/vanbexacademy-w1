

const BikeShare = {
  
  contract: null,
  currentUser: null,
  block: null,
  /**************************************
  * initializing the contract
  **************************************/
  async init() {
    console.log('BikeShare initialized');
    this.getWeb3();
    this.block = web3.eth.blockNumber;
    this.currentUser = web3.eth.accounts[0];
    const json = await fetch('../../build/contracts/BikeShare.json').then((res) => res.json());
    this.contract = await this.getContract(json);
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
      if (this[res.event]) this[res.event](res);
    });
  },
  //events
  async CreditsPurchased({ args }) {
    await APP.refreshCredits();
    await APP.refreshRental();
  },
  async BikeRented({ args }) {
    await APP.refreshBikes();
    await APP.refreshRental();
  },
  async BikeReturned({ args }) {
    await APP.refreshBikes();
    await APP.refreshRental();
  },
  async BikeRode({ args }) {
    await APP.refreshCredits();
    await APP.refreshRental();
  },
  /**************************************
  * helpers
  **************************************/
  getWeb3(fallbackURL = 'http://localhost:8545') {
    let web3;
    if (web3 !== undefined) {
      web3 = new Web3(web3.currentProvider);
    } else {
      web3 = new Web3(new Web3.providers.HttpProvider(fallbackURL));
    }
    window.web3 = web3;
    return web3;
  },
  async getContract(json, address, web3 = window.web3) {
    const contract = TruffleContract(json);
    contract.setProvider(web3.currentProvider);
    return address ? contract.at(address) : contract.deployed();
  }
};

