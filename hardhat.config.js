require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
    },
    n9997: {
      chainId: 9997,
      url: "http://192.168.1.240:9997"
    },
    n9998: {
      chainId: 9998,
      url: "http://192.168.1.240:9998"
    }
  },
};
