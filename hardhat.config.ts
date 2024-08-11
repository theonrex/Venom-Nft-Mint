import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
      },
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};

export default config;