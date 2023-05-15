//import "https://github.com/owner/repo/blob/branch/path/to/Contract.sol";




const hre = require("hardhat");
const assert = require("assert");

require("dotenv").config(); // yarn add dotenv
require('hardhat-deploy'); // yarn add hardhat-deploy npm install -D hardhat-deploy

async function makebalance(from,to,balance)
{
    totransfer = balance - ethers.utils.formatEther(await to.getBalance());
    //console.log(`totransfer = ${ethers.utils.formatEther(ethers.utils.parseEther(totransfer.toString()))}`)
    if (totransfer <=0) 
        return;
        tresp = await from.sendTransaction(
            {
                to: to.address,
                value: ethers.utils.parseEther("1.0")
            })
        await tresp.wait(1)
    console.log(`balance = ${ethers.utils.formatEther(await to.getBalance())}`)

}

async function main() {
    //const mainuser = await ethers.getSigner();
    
    const signer = await ethers.getSigner();
    console.log(`process.env.MAIN_PKEY = ${process.env.MAIN_PKEY}`);
    console.log(`process.env.DEPLOYER_PKEY = ${process.env.DEPLOYER_PKEY}`);
    const mainuser = new ethers.Wallet(process.env.MAIN_PKEY,ethers.provider)
    const deployer = new ethers.Wallet(process.env.DEPLOYER_PKEY,ethers.provider)

    console.log(`signer=${signer.address} balance=${ethers.utils.formatEther(await signer.getBalance())} nonce=${await signer.getTransactionCount()}`)
    console.log(`mainuser=${mainuser.address} balance=${ethers.utils.formatEther(await mainuser.getBalance())} nonce=${await mainuser.getTransactionCount()}`)
    console.log(`deployer=${deployer.address} balance=${ethers.utils.formatEther(await deployer.getBalance())} nonce=${await deployer.getTransactionCount()}`)

    if ((await signer.getBalance()) > 2.0) 
        await makebalance(signer,mainuser,2.0);
    if ((await mainuser.getBalance()) > 1.0) 
        await makebalance(mainuser,deployer,1.0)

    console.log(`mainuser=${mainuser.address} balance=${ethers.utils.formatEther(await mainuser.getBalance())} nonce=${await mainuser.getTransactionCount()}`)
    console.log(`deployer=${deployer.address} balance=${ethers.utils.formatEther(await deployer.getBalance())} nonce=${await deployer.getTransactionCount()}`)

    console.log(`deployer nonce=${await deployer.getTransactionCount()}`)

    if (await deployer.getTransactionCount() == 0) {
        console.log(`deploying Locator`)
        nonce = await deployer.getTransactionCount();
        const predicted = ethers.utils.getContractAddress({from: deployer.address,nonce})
        console.log(`\tnonce=${nonce} contract=${predicted}`)
        const Locator = await ethers.getContractFactory("Locator",deployer)
        console.log("\tDeploying contract...")
        const locator = await Locator.deploy()
        await locator.deployed()
        console.log(`\tDeployed contract to: ${locator.address}`)
        assert(locator.address == predicted)
    }
    
    const LocatorAddress = ethers.utils.getContractAddress({from: deployer.address,nonce:0})
  
    console.log(`LocatorAddress=${LocatorAddress}`)

    if (await deployer.getTransactionCount() == 1) {
        console.log(`transfering Locator to mainuser`)
        nonce = await deployer.getTransactionCount();
        const Locator = await ethers.getContractFactory("Locator",deployer)
        const locator = Locator.attach(LocatorAddress)
        console.log(`\tAttached locator to: ${locator.address}`)
        console.log(`\tLocator owner: ${await locator.ownerOf()}`)
        await locator.transfer(mainuser.address)
        console.log(`\tLocator new owner: ${await locator.ownerOf()}`)
    }



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
