const hre = require("hardhat");
const assert = require("assert");

require("dotenv").config(); // yarn add dotenv
require('hardhat-deploy'); // npm install -D hardhat-deploy

async function makebalance(from,to,balance)
{
    totransfer = balance - ethers.utils.formatEther(await to.getBalance());
    console.log(`totransfer = ${ethers.utils.formatEther(ethers.utils.parseEther(totransfer.toString()))}`)
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

async function deployer() {
    //const mainuser = await ethers.getSigner();
    const signer = await ethers.getSigner();
    console.log(`process.env.MAIN_PKEY = ${process.env.MAIN_PKEY}`);
    console.log(`process.env.DEPLOYER_PKEY = ${process.env.DEPLOYER_PKEY}`);
    const mainuser = new ethers.Wallet(process.env.MAIN_PKEY,ethers.provider)
    const deployer = new ethers.Wallet(process.env.DEPLOYER_PKEY,ethers.provider)

    console.log(`mainuser=${signer.address} balance=${ethers.utils.formatEther(await signer.getBalance())} nonce=${await signer.getTransactionCount()}`)
    console.log(`mainuser=${mainuser.address} balance=${ethers.utils.formatEther(await mainuser.getBalance())} nonce=${await mainuser.getTransactionCount()}`)
    console.log(`deployer=${deployer.address} balance=${ethers.utils.formatEther(await deployer.getBalance())} nonce=${await deployer.getTransactionCount()}`)

    await makebalance(signer,mainuser,1.0)
    await makebalance(signer,deployer,1.0)

    console.log(`mainuser=${mainuser.address} balance=${ethers.utils.formatEther(await mainuser.getBalance())} nonce=${await mainuser.getTransactionCount()}`)
    console.log(`deployer=${deployer.address} balance=${ethers.utils.formatEther(await deployer.getBalance())} nonce=${await deployer.getTransactionCount()}`)

    if (await deployer.getTransactionCount() == 0) {
        console.log(`deploying Locator`)
        nonce = await deployer.getTransactionCount();
        const anticipatedAddress = ethers.utils.getContractAddress({from: deployer.address,nonce})
        console.log(`\tnonce=${nonce} contract=${anticipatedAddress}`)
        const Locator = await ethers.getContractFactory("Locator",deployer)
        console.log("\tDeploying contract...")
        const locator = await Locator.deploy()
        await locator.deployed()
        console.log(`\tDeployed contract to: ${locator.address}`)
        assert(locator.address == process.env.LOCATOR)
    }
    if (await deployer.getTransactionCount() == 1) {
        console.log(`transfering Locator to mainuser`)
        nonce = await deployer.getTransactionCount();
        const Locator = await ethers.getContractFactory("Locator",deployer)
        const locator = Locator.attach(process.env.LOCATOR)
        console.log(`\tAttached locator to: ${locator.address}`)
        console.log(`\tLocator owner: ${await locator.ownerOf()}`)
        await locator.transfer(mainuser.address)
        console.log(`\tLocator new owner: ${await locator.ownerOf()}`)
    }



}



deployer()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })