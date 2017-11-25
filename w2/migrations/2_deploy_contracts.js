

const BikeShare = artifacts.require("./BikeShare.sol");

module.exports = (deployer) => {
  deployer.deploy(BikeShare);
};
