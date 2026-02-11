import { createConfig } from "ponder";

import { RaffleAbi } from "./abis/RaffleAbi";

export default createConfig({
  chains: {
    anvil: {
      id: 31337,
      rpc: "http://127.0.0.1:8545",
      disableCache: true,
    },
  },
  contracts: {
    Raffle: {
      chain: "anvil",
      abi: RaffleAbi,
      address: "0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9",
      startBlock: 0,
    },
  },
});
