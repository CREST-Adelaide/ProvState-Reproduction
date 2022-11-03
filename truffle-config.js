var HDWalletProvider = require("truffle-hdwallet-provider");
const privateKey = "baa68b3b6db96e8748467d05a2cdbdd8b97db1538a0cd8c91ea4bfb0576c2ffc";
const endpointUrl = "https://kovan.infura.io/v3/b7342a90975b4154992a5e2777ba73f6";

const MNEMONIC = 'divorce slight escape swarm salad sunset wall certain pyramid punch save episode'
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "5777",
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider(MNEMONIC, "https://kovan.infura.io/v3/78470388123047a2bf23b0b73389d7c9")
      },
      network_id: 42,
      gas: 5000000,
      gasPrice: 25000000000
    }
  },
  // contracts_directory: './src/contracts/',
  // contracts_build_directory: './src/abis/',
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}
