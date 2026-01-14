// =============================================================================
// Contract ABIs - YieldBrick
// Generated from Solidity contracts for frontend integration
// =============================================================================

export const YIELD_VAULT_ABI = [
  // Read Functions
  {
    name: "getUserDashboard",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "user", type: "address" }],
    outputs: [
      { name: "principal", type: "uint256" },
      { name: "shares", type: "uint256" },
      { name: "pendingYield", type: "uint256" },
      { name: "totalHarvested", type: "uint256" },
      { name: "targetAssetId", type: "uint256" },
      { name: "rwaValue", type: "uint256" },
    ],
  },
  {
    name: "getYieldProgress",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "user", type: "address" }],
    outputs: [
      { name: "currentYield", type: "uint256" },
      { name: "targetPrice", type: "uint256" },
      { name: "progressBps", type: "uint256" },
      { name: "fractionsEarned", type: "uint256" },
    ],
  },
  {
    name: "getProtocolStats",
    type: "function",
    stateMutability: "view",
    inputs: [],
    outputs: [
      { name: "totalDeposits", type: "uint256" },
      { name: "totalUsers", type: "uint256" },
      { name: "protocolYield", type: "uint256" },
      { name: "rwaValue", type: "uint256" },
    ],
  },
  {
    name: "calculatePendingYield",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "user", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    name: "balanceOf",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "account", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    name: "totalAssets",
    type: "function",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
  },
  // Write Functions
  {
    name: "deposit",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "assets", type: "uint256" },
      { name: "receiver", type: "address" },
    ],
    outputs: [{ name: "shares", type: "uint256" }],
  },
  {
    name: "withdraw",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "assets", type: "uint256" },
      { name: "receiver", type: "address" },
      { name: "owner", type: "address" },
    ],
    outputs: [{ name: "shares", type: "uint256" }],
  },
  {
    name: "harvestAndBuy",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [],
    outputs: [
      { name: "fractionsBought", type: "uint256" },
      { name: "yieldUsed", type: "uint256" },
    ],
  },
  {
    name: "setTargetAsset",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [{ name: "assetId", type: "uint256" }],
    outputs: [],
  },
  {
    name: "mockYield",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [{ name: "amount", type: "uint256" }],
    outputs: [],
  },
  // Events
  {
    name: "YieldHarvested",
    type: "event",
    inputs: [
      { name: "user", type: "address", indexed: true },
      { name: "yieldAmount", type: "uint256", indexed: false },
      { name: "rwaAssetId", type: "uint256", indexed: true },
      { name: "fractionsBought", type: "uint256", indexed: false },
      { name: "timestamp", type: "uint256", indexed: false },
    ],
  },
] as const;

export const RWA_TOKEN_ABI = [
  // Read Functions
  {
    name: "getAssetInfo",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "assetId", type: "uint256" }],
    outputs: [
      {
        name: "",
        type: "tuple",
        components: [
          { name: "name", type: "string" },
          { name: "symbol", type: "string" },
          { name: "description", type: "string" },
          { name: "pricePerFraction", type: "uint256" },
          { name: "totalValue", type: "uint256" },
          { name: "totalFractions", type: "uint256" },
          { name: "mantleDARef", type: "string" },
          { name: "imageURI", type: "string" },
          { name: "isActive", type: "bool" },
          { name: "apy", type: "uint256" },
        ],
      },
    ],
  },
  {
    name: "getUserPortfolio",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "user", type: "address" }],
    outputs: [
      { name: "assetIds", type: "uint256[]" },
      { name: "balances", type: "uint256[]" },
      { name: "values", type: "uint256[]" },
    ],
  },
  {
    name: "getAllAssetIds",
    type: "function",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "", type: "uint256[]" }],
  },
  {
    name: "balanceOf",
    type: "function",
    stateMutability: "view",
    inputs: [
      { name: "account", type: "address" },
      { name: "id", type: "uint256" },
    ],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    name: "totalSupply",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "id", type: "uint256" }],
    outputs: [{ name: "", type: "uint256" }],
  },
] as const;

export const MOCK_METH_ABI = [
  {
    name: "faucet",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [{ name: "amount", type: "uint256" }],
    outputs: [],
  },
  {
    name: "approve",
    type: "function",
    stateMutability: "nonpayable",
    inputs: [
      { name: "spender", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    outputs: [{ name: "", type: "bool" }],
  },
  {
    name: "balanceOf",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "account", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    name: "allowance",
    type: "function",
    stateMutability: "view",
    inputs: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
    ],
    outputs: [{ name: "", type: "uint256" }],
  },
] as const;
