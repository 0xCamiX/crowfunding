var CrowFundingV7 = artifacts.require("./CrowFundingV7.sol");

module.exports = async function(deployer){
    await deployer.deploy(CrowFundingV7)
}