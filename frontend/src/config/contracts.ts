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
  {
    type: "function",
    name: "getPrizePool",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getPlayersCount",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getEntriesCount",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "enterRaffle",
    inputs: [],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "event",
    name: "RaffleEntered",
    inputs: [
      { name: "roundNumber", type: "uint256", indexed: true, internalType: "uint256" },
      { name: "player", type: "address", indexed: true, internalType: "address" },
    ],
  },
  {
    type: "event",
    name: "DrawCompleted",
    inputs: [
      { name: "roundNumber", type: "uint256", indexed: true, internalType: "uint256" },
      { name: "winner", type: "address", indexed: true, internalType: "address" },
      { name: "prize", type: "uint256", indexed: false, internalType: "uint256" },
    ],
  },
] as const;
