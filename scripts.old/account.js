
const { ethers } = require("hardhat");

require("dotenv").config()

async function main() {
    //console.dir(ethers.provider)
    const provider = ethers.provider
    console.dir(await provider.getNetwork())
    console.log(`getBlockNumber = ${await provider.getBlockNumber()}`)

    const mainuser = await ethers.getSigner();
    const deployer = new ethers.Wallet(process.env.DEPLOYER_PKEY,provider)

    console.log(`mainuser=${mainuser.address} balance=${await mainuser.getBalance()} nonce=${await mainuser.getTransactionCount()}`)
    console.log(`deployer=${deployer.address} balance=${await deployer.getBalance()} nonce=${await deployer.getTransactionCount()}`)


    tresp = await mainuser.sendTransaction(
        {
            to: deployer.address,
            value: ethers.utils.parseEther("1.0"),
            //gasPrice: "1875000000" ,
            maxPriorityFeePerGas: "1000000000" ,
            maxFeePerGas: "2750000000" ,
            gasLimit: "21001" 
        })
    console.log(tresp)
    trecp = await tresp.wait(1)
    console.log(trecp)
    console.log(await provider.getBlock(trecp.blockNumber))
    console.log(await provider.getTransaction(trecp.transactionHash))
    console.log(await provider.getTransactionReceipt(trecp.transactionHash))

    console.log(`deployer=${mainuser.address} balance=${await deployer.getBalance()} nonce=${await deployer.getTransactionCount()}`)

    return

    //console.log(`typeof =${typeof account}`)
    console.log(`balance = ${await main.getBalance()}`)
    console.log(`balance deployer = ${await deployer.getBalance()}`)
    console.dir(main)
    console.dir(deployer)
    // Send a transaction
    transactionResponse = await main.sendTransaction(
        {
            to: deployer.address,
            value: ethers.utils.parseEther("1.0"),
            gasPrice: "21488430592"
        })
    console.log(transactionResponse)
    t = await transactionResponse.wait(1)
    console.log(t)

    console.log(`balance deployer = ${await deployer.getBalance()}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })