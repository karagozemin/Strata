// =============================================================================
// Contract Addresses - YieldBrick
// Update these after deployment to Mantle Testnet/Mainnet
// =============================================================================

export const CONTRACTS = {
  // Mantle Testnet Sepolia (Chain ID: 5003)
  mantleTestnet: {
    mockMETH: "0x0000000000000000000000000000000000000000" as `0x${string}`,
    rwaToken: "0x0000000000000000000000000000000000000000" as `0x${string}`,
    yieldVault: "0x0000000000000000000000000000000000000000" as `0x${string}`,
  },
  // Mantle Mainnet (Chain ID: 5000)
  mantleMainnet: {
    mETH: "0xcDA86A272531e8640cD7F1a92c01839911B90bb0" as `0x${string}`, // Real mETH address
    rwaToken: "0x0000000000000000000000000000000000000000" as `0x${string}`,
    yieldVault: "0x0000000000000000000000000000000000000000" as `0x${string}`,
  },
} as const;

// Helper to get addresses for current chain
export function getContractAddresses(chainId: number) {
  switch (chainId) {
    case 5003:
      return CONTRACTS.mantleTestnet;
    case 5000:
      return CONTRACTS.mantleMainnet;
    default:
      return CONTRACTS.mantleTestnet;
  }
}
