

const Bike = artifacts.require("./Bike.sol");

module.exports = (deployer) => {
  deployer.deploy(Bike);
};
