var Escrow = artifacts.require("Escrow");
// arbitratorAddress = "0x3b1b31f1a805C36Af1CFe12237549EdcB5370B3a";
module.exports = function (deployer) {
  // deployment steps
  deployer.deploy(Escrow, "0x3b1b31f1a805C36Af1CFe12237549EdcB5370B3a"); // deployment of the proxy contract and passing the owner address we want to set
};
