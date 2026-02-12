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
      address: process.env.RAFFLE_CONTRACT_ADDRESS as `0x${string}`,
      startBlock: 0,
    },
  },
});
