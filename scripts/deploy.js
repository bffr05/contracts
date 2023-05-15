
const hre = require("hardhat");
const assert = require("assert");

require("dotenv").config(); // yarn add dotenv
require('hardhat-deploy'); // yarn add hardhat-deploy npm install -D hardhat-deploy

let LocatorAddress = "0x455b153B592d4411dCf5129643123639dcF3c806";
const EthAddress0 = "0x0000000000000000000000000000000000000000";

const kAccess = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("Access"));
const kTokenPlace = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("TokenPlace"));
const kOracle = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("Oracle"));
const kForwarder_Deployer = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("Forwarder_Deployer"));
const kMEquivFT = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("MEquivFT"));
const kMEquivNFT = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("MEquivNFT"));
const kGate = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("Gate"));
const kMulticall = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("Multicall"));

myLocator = EthAddress0

async function makebalance(from,to,balance)
{
    totransfer = balance - ethers.utils.formatEther(await to.getBalance());
    // console.log(`totransfer = ${ethers.utils.formatEther(ethers.utils.parseEther(totransfer.toString()))}`)
    if (totransfer <=0) 
        return;
        tresp = await from.sendTransaction(
            {
                to: to.address,
                value: ethers.utils.parseEther("1.0")
            })
        await tresp.wait(1)
    // console.log(`balance = ${ethers.utils.formatEther(await to.getBalance())}`)

}



async function main() {
  console.log(`kAccess = ${kAccess}`);
  console.log(`kTokenPlace = ${kTokenPlace}`);
  console.log(`kOracle = ${kOracle}`);
  console.log(`kForwarder_Deployer = ${kForwarder_Deployer}`);
  console.log(`kMEquivFT = ${kMEquivFT}`);
  console.log(`kMEquivNFT = ${kMEquivNFT}`);
  console.log(`kGate = ${kGate}`);
  console.log(`kMulticall = ${kMulticall}`);
  console.log("\n")


  const signer = await ethers.getSigner();
  console.log(`process.env.MAIN_PKEY = ${process.env.MAIN_PKEY}`);
  const mainuser = new ethers.Wallet(process.env.MAIN_PKEY,ethers.provider)
  console.log("\n")


  console.log(`signer=${signer.address} balance=${ethers.utils.formatEther(await signer.getBalance())} nonce=${await signer.getTransactionCount()}`)
  await makebalance(signer,mainuser,1.0)
  console.log(`mainuser=${mainuser.address} balance=${ethers.utils.formatEther(await mainuser.getBalance())} nonce=${await mainuser.getTransactionCount()}`)
  console.log("\n")




  let nolocator = (await ethers.provider.getCode(LocatorAddress)).length<=2;
  if (nolocator) {
    const Locator = await ethers.getContractFactory("Locator",mainuser);
    const locator = await Locator.deploy();
    console.log(`deploying Locator`);
    await locator.deployed();
    console.log("Locator deployed");
    LocatorAddress = locator.address;
  }
  const locator = await ethers.getContractAt("ILocator", LocatorAddress,mainuser);
  console.log(`LocatorAddress=${LocatorAddress}`);
  console.log("\n");


  if (true) {
    const Access = await ethers.getContractFactory("Access",mainuser);
    const access = await Access.deploy();
    console.log(`deploying Access`);
    await access.deployed();
    console.log("Access deployed");

    if (nolocator) {
      await access.setLocator(LocatorAddress);
      assert((await access.locator())==LocatorAddress);
    }
    console.log(`Access Locator=${await access.locator()}`);

    await locator["set(bytes32,address)"](kAccess,access.address);
  }
  const access = await ethers.getContractAt("IRTrustable", await locator.get(kAccess),mainuser);
  console.log(`Locator(Access)=${await locator.get(kAccess)}`);
  console.log("\n");


  if (true) {
    const TokenPlace = await ethers.getContractFactory("TokenPlace",mainuser);
    const tokenplace = await TokenPlace.deploy();
    console.log(`deploying TokenPlace`);
    await tokenplace.deployed();
    console.log("TokenPlace deployed");

    if (nolocator) {
      await tokenplace.setLocator(LocatorAddress);
      assert((await tokenplace.locator())==LocatorAddress);
    }
    console.log(`TokenPlace Locator=${await tokenplace.locator()}`);
    console.log(`TokenPlace referral=${await tokenplace.referral()}`);
    assert((await tokenplace.referral())==(await locator.get(kAccess)));

    await locator["set(bytes32,address)"](kTokenPlace,tokenplace.address);
    await access.setContract(tokenplace.address,true) ;

  }
  console.log(`Locator(TokenPlace)=${await locator.get(kTokenPlace)}`);
  console.log("\n");


  if (true) {
    const Oracle = await ethers.getContractFactory("Oracle",mainuser);
    const oracle = await Oracle.deploy();
    console.log(`deploying Oracle`);
    await oracle.deployed();
    console.log("Oracle deployed");

    if (nolocator) {
      await oracle.setLocator(LocatorAddress);
      assert((await oracle.locator())==LocatorAddress);
    }
    console.log(`Oracle Locator=${await oracle.locator()}`);
    console.log(`Oracle referral=${await oracle.referral()}`);
    assert((await oracle.referral())==(await locator.get(kAccess)));

    await locator["set(bytes32,address)"](kOracle,oracle.address);
    await access.setContract(oracle.address,true) ;

  }
  console.log(`Locator(Oracle)=${await locator.get(kOracle)}`);
  console.log("\n");


  if (true) {
    const Forwarder_Deployer = await ethers.getContractFactory("Forwarder_Deployer",mainuser);
    const forwarder = await Forwarder_Deployer.deploy();
    console.log(`deploying Forwarder_Deployer`);
    await forwarder.deployed();
    console.log("Forwarder_Deployer deployed");

    await locator["set(bytes32,address)"](kForwarder_Deployer,forwarder.address);

  }
  console.log(`Locator(Forwarder_Deployer)=${await locator.get(kForwarder_Deployer)}`);
  console.log("\n");



  if (true) {
    const MEquivNFT = await ethers.getContractFactory("MEquivNFT",mainuser);
    const nft = await MEquivNFT.deploy();
    console.log(`deploying MEquivNFT`);
    await nft.deployed();
    console.log("MEquivNFT deployed");

    if (nolocator) {
      await nft.setLocator(LocatorAddress);
      assert((await nft.locator())==LocatorAddress);
    }
    console.log(`MEquivNFT Locator=${await nft.locator()}`);
    console.log(`MEquivNFT referral=${await nft.referral()}`);
    assert((await nft.referral())==(await locator.get(kAccess)));

    await locator["set(bytes32,address)"](kMEquivNFT,nft.address);
    await access.setContract(nft.address,true) ;

  }
  console.log(`Locator(MEquivNFT)=${await locator.get(kMEquivNFT)}`);
  console.log("\n");


  if (true) {
    const MEquivFT = await ethers.getContractFactory("MEquivFT",mainuser);
    const ft = await MEquivFT.deploy();
    console.log(`deploying MEquivFT`);
    await ft.deployed();
    console.log("MEquivFT deployed");

    if (nolocator) {
      await ft.setLocator(LocatorAddress);
      assert((await ft.locator())==LocatorAddress);
    }
    console.log(`MEquivFT Locator=${await ft.locator()}`);
    console.log(`MEquivFT referral=${await ft.referral()}`);
    assert((await ft.referral())==(await locator.get(kAccess)));

    await locator["set(bytes32,address)"](kMEquivFT,ft.address);
    await access.setContract(ft.address,true) ;

  }
  console.log(`Locator(MEquivFT)=${await locator.get(kMEquivFT)}`);
  console.log("\n");


  if (true) {

    const GateLibTransfer = await ethers.getContractFactory("GateLibTransfer",mainuser);
    const gatelibtransfer = await GateLibTransfer.deploy();
    console.log(`deploying GateLibTransfer`);
    await gatelibtransfer.deployed();
    console.log("GateLibTransfer deployed");

    const GateLibTranscript = await ethers.getContractFactory("GateLibTranscript",mainuser);
    const gatelibtranscript = await GateLibTranscript.deploy();
    console.log(`deploying GateLibTranscript`);
    await gatelibtranscript.deployed();
    console.log("GateLibTranscript deployed");
    
    const GateLibUtil = await ethers.getContractFactory("GateLibUtil",{ signer: mainuser, libraries: { GateLibTransfer: gatelibtransfer.address,GateLibTranscript:gatelibtranscript.address } });
    const gatelibutil = await GateLibUtil.deploy();
    console.log(`deploying GateLibUtil`);
    await gatelibutil.deployed();
    console.log("GateLibUtil deployed");

    const GateLibProcessMessage = await ethers.getContractFactory("GateLibProcessMessage",{ signer: mainuser, libraries: { GateLibUtil: gatelibutil.address, GateLibTransfer: gatelibtransfer.address,GateLibTranscript:gatelibtranscript.address } });
    const gatelibprocessmessage = await GateLibProcessMessage.deploy();
    console.log(`deploying GateLibProcessMessage`);
    await gatelibprocessmessage.deployed();
    console.log("GateLibProcessMessage deployed");



    const Gate = await ethers.getContractFactory("Gate",{ signer: mainuser, libraries: { GateLibProcessMessage: gatelibprocessmessage.address, GateLibUtil: gatelibutil.address, GateLibTransfer: gatelibtransfer.address,GateLibTranscript:gatelibtranscript.address } });
    const gate = await Gate.deploy();
    console.log(`deploying Gate`);
    await gate.deployed();
    console.log("Gate deployed");

    if (nolocator) {
      await gate.setLocator(LocatorAddress);
      assert((await gate.locator())==LocatorAddress);
    }
    console.log(`Gate Locator=${await gate.locator()}`);
    console.log(`Gate referral=${await gate.referral()}`);
    assert((await gate.referral())==(await locator.get(kAccess)));

    await locator["set(bytes32,address)"](kGate,gate.address);
    await access.setContract(gate.address,true) ;

  }
  console.log(`Locator(Gate)=${await locator.get(kGate)}`);
  console.log("\n");

}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
