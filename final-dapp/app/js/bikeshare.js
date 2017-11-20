

const BikeShare = {
  
  bikeshare: null,
  /**************************************
  * initializing the contract
  **************************************/
  async init() {
    console.log('BikeShare initialized');
    this.getWeb3();
    const json = await fetch('../../build/contracts/BikeShare.json').then((res) => res.json());
    this.bikeshare = await this.getContract(json);
  },
  /**************************************
  * contract functions
  **************************************/
  async purchaseCredits(value) {
    const { bikeshare } = this;
    const owner = web3.eth.accounts[0];
    
    const tx = await bikeshare.sendTransaction({
      from: owner,
      value: web3.toWei(value, 'ether')
    });
    const credits = await bikeshare.credits.call(owner);
    console.log('Credits Purchased', credits);
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



/**************************************
* Comment
**************************************/



const web3funcs = (function() {
    
  /**************************************
  * Get Web3
  **************************************/
  const getWeb3 = (fallbackURL = 'http://localhost:8545', web3 = window.web3) => {
    if (web3 !== undefined) {
      web3 = new Web3(web3.currentProvider);
    } else {
      web3 = new Web3(new Web3.providers.HttpProvider(fallbackURL));
    }
    window.web3 = web3;
    return web3;
  };
  const setWeb3 = (url = 'http://localhost:8545') => {
    web3 = new Web3(new Web3.providers.HttpProvider(url));
    window.web3 = web3;
    return web3;
  };
  /**************************************
  * Get Network
  **************************************/
  const getNetwork = (web3 = window.web3) => new Promise((resolve, reject) => {
    if (!web3) {
      console.log('No web3 instance provided');
      return;
    }
    let id, name;
    web3.version.getNetwork((err, networkId) => {
      if (err) {
        reject(err); return;
      }
      id = parseInt(networkId);
      switch (id) {
        case 1: name = 'mainnet'; break;
        case 2: name = 'morden'; break;
        case 3: name = 'ropsten'; break;
        case 4: name = 'rinkeby'; break;
        case 42: name = 'kovan'; break;
        default: name = 'localhost';
      }
      console.log('The network is:', name, id);
      resolve({ id, name });
    });
  });
  /**************************************
  * Get Accounts (with promise)
  **************************************/
  const getAccounts = (web3 = window.web3) => new Promise((resolve, reject) => {
    if (!web3) reject('No web3 instance provided');
    //checking for accounts, keep track of attempts
    let accounts, attempts = 0;
    //limit attempts
    const limit = 5;
    //check function
    const check = () => {
      accounts = web3.eth.accounts;
      if (accounts.length > 0) {
        resolve(accounts);
      } else {
        attempts++;
        if (attempts === limit) {
          reject('accounts could not be found on web3 provider');
          return;
        }
        setTimeout(check, 200); //found no accounts, below attempt limit, check again
      }
    };
    check();
  });
  /**************************************
  * Get Contract
  **************************************/
  const getContract = (json, address, web3 = window.web3) => {
    const contract = TruffleContract(json);
    contract.setProvider(web3.currentProvider);
    return address ? contract.at(address) : contract.deployed();
  };
  /**************************************
  * Deploy Contract
  **************************************/
  const deployContract = (json, from, gas) => {
    const contract = TruffleContract(json);
    contract.setProvider(web3.currentProvider);
    contract.new({
      from, gas
    });
  };
  /**************************************
  * Wait for Confirmations
  **************************************/
  const waitFor = (tx) => new Promise((resolve, reject) => {
    const block = tx.receipt.blockNumber;
    console.log('waitFor: transaction to pass block #', block);
    //tracking
    let i;
    const limit = 30; //2 minute wait
    //check block
    const check = () => {
      web3.eth.getBlockNumber((err, res) => {
        console.log('latest block #', res);
        if (res > block) {
          resolve();
          return;
        } else if (i > limit) {
          reject();
          return;
        }
        i++;
        setTimeout(check, 4000); //check every 4s
      });
    };
    check();
  });
  /**************************************
  * Helpers
  **************************************/
  const roundTo = (num, dec) => {
    const factor = Math.pow(10, dec);
    return Math.round(num * factor) / factor;
  };
  
  const promisify = (inner) => new Promise((resolve, reject) =>
    inner((err, res) => {
      if (err) { reject(err) }
      resolve(res);
    })
  );
  const getBalance = (account, at) => promisify((cb) => web3.eth.getBalance(account, at, cb));
  const timeout = ms => new Promise(res => setTimeout(res, ms));
  const toEth = (wei) => window.web3.fromWei(wei, 'ether').toNumber();
  const toWei = (eth) => window.web3.toWei(eth, 'ether');
  const toUSD = (eth) => new Promise((resolve, reject) =>
    fetch('https://api.coinmarketcap.com/v1/ticker/ethereum/?convert=USD').then((res) =>
      res.json()).then((res) => resolve(roundTo(parseFloat(eth * res[0].price_usd), 2))));
  
  return {
    getWeb3,
    setWeb3,
    getNetwork,
    getAccounts,
    getContract,
    deployContract,
    waitFor,
    getBalance,
    timeout,
    toEth,
    toWei,
    toUSD
  };
  
})();

try {
  module.exports = web3funcs;
} catch(e) {}

