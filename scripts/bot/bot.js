const hre = require("hardhat");
const assert = require("assert");

require("dotenv").config(); // yarn add dotenv
var fs = require('fs');
const { exit } = require("process");

let LocatorAddress = "0xCC41D983Af9b191209e572D6F9871434019D35F4";
const EthAddress0 = "0x0000000000000000000000000000000000000000";


function botaccountpriv() {
    return process.env.BOT_PKEY
}
const bot = new ethers.Wallet(botaccountpriv(),ethers.provider)
function botaccount() {
    return bot;
}

async function main() {
    console.log(`BOT_PKEY = ${botaccountpriv()}`);
    console.log(`BOT_PUBKEY = ${botaccount().address}`);
    console.log("\n")
    // console.dir(hre.config);
    // console.dir(hre.config.networks);
    // console.log(`hre.config = ${JSON.stringify(hre.config)}`);
    const signer = await ethers.getSigner();

    const config = [];

    data = fs.readFileSync('network.json', 'ascii');
    const networkjson = JSON.parse(data);
    //console.dir(networkjson);

    console.dir(config);
    for (entry in networkjson) {
        obj = networkjson[entry];
        obj.provider = new ethers.providers.JsonRpcProvider(obj.host);
        obj.network = await obj.provider.getNetwork();
        //console.log(`provider.getNetwork() = ${}`);
        config.push(obj);
    }

    // for (entry in networkjson) {
    //     console.dir(networkjson[entry]);
    // }
    console.dir(config);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  