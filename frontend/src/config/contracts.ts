import { type Address } from "viem";

export const RAFFLE_ADDRESS = import.meta.env
  .VITE_RAFFLE_CONTRACT_ADDRESS as Address;

export const RAFFLE_ABI = [
  {
    type: "function",
    name: "getEntranceFee",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getEntryDeadline",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
] as const;
