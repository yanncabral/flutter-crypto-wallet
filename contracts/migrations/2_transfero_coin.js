const TransferoCoin = artifacts.require("TransferoCoin");

module.exports = function (deployer) {
  deployer.deploy(TransferoCoin);
};
