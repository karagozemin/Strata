// =============================================================================
// Contract Addresses - Strata
// Update these after deployment to Mantle Testnet/Mainnet
// =============================================================================

export const CONTRACTS = {
  // Mantle Testnet Sepolia (Chain ID: 5003)
  mantleTestnet: {
    mETH: "0xB7Ab966115aF7d21E7Aa6e31A9AdfC92291092E0" as `0x${string}`,
    rwaToken: "0xa520c7Aa947f3B610d274377D261Eb5AcD70883F" as `0x${string}`,
    yieldVault: "0x9C70C2F67028e5464F5b60E29648240e358E83B6" as `0x${string}`,
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
