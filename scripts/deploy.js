// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { ethers, utils } = require("ethers");

const LocatorAddress = "0x455b153B592d4411dCf5129643123639dcF3c806";
const kAccess = utils.keccak256(utils.toUtf8Bytes("Access"));
const kForwarder_Deployer = utils.keccak256(utils.toUtf8Bytes("Forwarder_Deployer"));

let deployer = hre.ethers.Wallet(getenv("DEPLOYER_PKEY"))

// def mainaccount():
//     if network.show_active() in {"development", "ganache"}:
//         return accounts[0]
//     else:
//         return accounts.add(os.getenv("MAIN_PKEY"))

// def extraaccount():
//     if network.show_active() in {"development", "ganache"}:
//         return accounts[1]
//     else:
//         return accounts.add(os.getenv("EXTRA_PKEY"))

// def deployeraccount():
//     if network.show_active() in {"development", "ganache"}:
//         return accounts[1]
//     else:
//         return accounts.add(os.getenv("DEPLOYER_PKEY"))


async function main() {


  let myLocator = LocatorAddress ;
  console.log(`provider = ${hre.ethers.provider}`)
  console.log(`getCode = ${await hre.ethers.provider.getCode(myLocator)}`)
  console.log(`getCode len= ${(await hre.ethers.provider.getCode(myLocator)).length}`)
  const nolocator = (await hre.ethers.provider.getCode(myLocator)).length <= 2 ;
  console.log(`nolocator = ${nolocator}`)

  if (nolocator) {
      const Locator = await hre.ethers.getContractFactory("Locator");
      const locator = await Locator.deploy();
  }
  // if nolocator and len(Locator) > 0:
  //     myLocator = Locator[-1].address
  // if nolocator:
  //     Locator.deploy({"from": mainaccount()})
  //     myLocator = Locator[-1].address
  // print(f"LocatorAddress = {myLocator}")
  // print(f"nolocator = {nolocator}")
  // print(f"len = {len(network.web3.eth.get_code(myLocator))}")

  // const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  // const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  // const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

  // const lockedAmount = hre.ethers.utils.parseEther("1");

  // const Lock = await hre.ethers.getContractFactory("Lock");
  // const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  // await lock.deployed();

  // console.log(
  //   `Lock with 1 ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`
  // );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
