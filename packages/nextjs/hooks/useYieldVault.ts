// =============================================================================
// useYieldVault.ts - Custom Hook for YieldVault Contract Interactions
// Strata - Mantle Global Hackathon 2025
// =============================================================================

import { useAccount, useChainId, useReadContract, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { formatEther, parseEther } from "viem";
import { YIELD_VAULT_ABI, MOCK_METH_ABI } from "../contracts/abis";
import { getContractAddresses } from "../contracts/addresses";

/**
 * Custom hook for interacting with the YieldVault contract
 * Provides all vault-related read and write operations
 */
export function useYieldVault() {
  const { address } = useAccount();
  const chainId = useChainId();
  const contracts = getContractAddresses(chainId);

  // =========================================================================
  // READ OPERATIONS
  // =========================================================================

  /**
   * Get user's dashboard data
   * Returns: principal, shares, pendingYield, totalHarvested, targetAssetId, rwaValue
   */
  const { data: dashboardData, refetch: refetchDashboard, isLoading: isDashboardLoading } = useReadContract({
    address: contracts.yieldVault,
    abi: YIELD_VAULT_ABI,
    functionName: "getUserDashboard",
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  /**
   * Get user's yield progress towards next RWA fraction
   * Returns: currentYield, targetPrice, progressBps, fractionsEarned
   */
  const { data: yieldProgress, refetch: refetchProgress } = useReadContract({
    address: contracts.yieldVault,
    abi: YIELD_VAULT_ABI,
    functionName: "getYieldProgress",
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  /**
   * Get protocol-wide statistics
   * Returns: totalDeposits, totalUsers, protocolYield, rwaValue
   */
  const { data: protocolStats, refetch: refetchStats } = useReadContract({
    address: contracts.yieldVault,
    abi: YIELD_VAULT_ABI,
    functionName: "getProtocolStats",
    query: {
      enabled: true,
    },
  });

  /**
   * Get user's pending yield
   */
  const { data: pendingYield } = useReadContract({
    address: contracts.yieldVault,
    abi: YIELD_VAULT_ABI,
    functionName: "calculatePendingYield",
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  /**
   * Get user's vault shares balance
   */
  const { data: sharesBalance } = useReadContract({
    address: contracts.yieldVault,
    abi: YIELD_VAULT_ABI,
    functionName: "balanceOf",
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  /**
   * Get total vault assets (TVL)
   */
  const { data: totalAssets } = useReadContract({
    address: contracts.yieldVault,
    abi: YIELD_VAULT_ABI,
    functionName: "totalAssets",
    query: {
      enabled: true,
    },
  });

  // =========================================================================
  // WRITE OPERATIONS
  // =========================================================================

  const { writeContract, data: txHash, isPending: isWritePending, error: writeError } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash: txHash,
  });

  /**
   * Deposit mETH into the vault
   */
  const deposit = async (amount: string) => {
    if (!address) throw new Error("Wallet not connected");
    
    const amountWei = parseEther(amount);
    
    writeContract({
      address: contracts.yieldVault,
      abi: YIELD_VAULT_ABI,
      functionName: "deposit",
      args: [amountWei, address],
    });
  };

  /**
   * Withdraw mETH from the vault
   */
  const withdraw = async (amount: string) => {
    if (!address) throw new Error("Wallet not connected");
    
    const amountWei = parseEther(amount);
    
    writeContract({
      address: contracts.yieldVault,
      abi: YIELD_VAULT_ABI,
      functionName: "withdraw",
      args: [amountWei, address, address],
    });
  };

  /**
   * Harvest yield and buy RWA fractions
   */
  const harvestAndBuy = async () => {
    if (!address) throw new Error("Wallet not connected");
    
    writeContract({
      address: contracts.yieldVault,
      abi: YIELD_VAULT_ABI,
      functionName: "harvestAndBuy",
      args: [],
    });
  };

  /**
   * Set target RWA asset for purchases
   */
  const setTargetAsset = async (assetId: number) => {
    if (!address) throw new Error("Wallet not connected");
    
    writeContract({
      address: contracts.yieldVault,
      abi: YIELD_VAULT_ABI,
      functionName: "setTargetAsset",
      args: [BigInt(assetId)],
    });
  };

  /**
   * Add mock yield (for demo purposes)
   */
  const mockYield = async (amount: string) => {
    if (!address) throw new Error("Wallet not connected");
    
    const amountWei = parseEther(amount);
    
    writeContract({
      address: contracts.yieldVault,
      abi: YIELD_VAULT_ABI,
      functionName: "mockYield",
      args: [amountWei],
    });
  };

  // =========================================================================
  // FORMATTED DATA
  // =========================================================================

  const formattedDashboard = dashboardData ? {
    principal: formatEther(dashboardData[0] as bigint),
    shares: formatEther(dashboardData[1] as bigint),
    pendingYield: formatEther(dashboardData[2] as bigint),
    totalHarvested: formatEther(dashboardData[3] as bigint),
    targetAssetId: Number(dashboardData[4]),
    rwaValue: formatEther(dashboardData[5] as bigint),
  } : null;

  const formattedProgress = yieldProgress ? {
    currentYield: formatEther(yieldProgress[0] as bigint),
    targetPrice: formatEther(yieldProgress[1] as bigint),
    progressPercent: Number(yieldProgress[2]) / 100, // Convert bps to percent
    fractionsEarned: Number(yieldProgress[3]),
  } : null;

  const formattedStats = protocolStats ? {
    totalDeposits: formatEther(protocolStats[0] as bigint),
    totalUsers: Number(protocolStats[1]),
    protocolYield: formatEther(protocolStats[2] as bigint),
    rwaValue: formatEther(protocolStats[3] as bigint),
  } : null;

  // =========================================================================
  // RETURN HOOK DATA
  // =========================================================================

  return {
    // Read data
    dashboard: formattedDashboard,
    yieldProgress: formattedProgress,
    protocolStats: formattedStats,
    pendingYield: pendingYield ? formatEther(pendingYield as bigint) : "0",
    sharesBalance: sharesBalance ? formatEther(sharesBalance as bigint) : "0",
    totalAssets: totalAssets ? formatEther(totalAssets as bigint) : "0",

    // Loading states
    isLoading: isDashboardLoading,
    isWritePending,
    isConfirming,
    isConfirmed,

    // Errors
    writeError,

    // Write functions
    deposit,
    withdraw,
    harvestAndBuy,
    setTargetAsset,
    mockYield,

    // Refetch functions
    refetch: () => {
      refetchDashboard();
      refetchProgress();
      refetchStats();
    },
  };
}

/**
 * Hook for mETH token operations (approve, balance)
 */
export function useMETH() {
  const { address } = useAccount();
  const chainId = useChainId();
  const contracts = getContractAddresses(chainId);

  const { data: balance, refetch: refetchBalance } = useReadContract({
    address: contracts.mETH,
    abi: MOCK_METH_ABI,
    functionName: "balanceOf",
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  const { data: allowance, refetch: refetchAllowance } = useReadContract({
    address: contracts.mETH,
    abi: MOCK_METH_ABI,
    functionName: "allowance",
    args: address ? [address, contracts.yieldVault] : undefined,
    query: {
      enabled: !!address,
    },
  });

  const { writeContract, data: txHash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash: txHash,
  });

  const approve = async (amount: string) => {
    const amountWei = parseEther(amount);
    
    writeContract({
      address: contracts.mETH,
      abi: MOCK_METH_ABI,
      functionName: "approve",
      args: [contracts.yieldVault, amountWei],
    });
  };

  const approveMax = async () => {
    writeContract({
      address: contracts.mETH,
      abi: MOCK_METH_ABI,
      functionName: "approve",
      args: [contracts.yieldVault, BigInt("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")],
    });
  };

  return {
    balance: balance ? formatEther(balance as bigint) : "0",
    allowance: allowance ? formatEther(allowance as bigint) : "0",
    approve,
    approveMax,
    isPending,
    isConfirming,
    isConfirmed,
    refetch: () => {
      refetchBalance();
      refetchAllowance();
    },
  };
}
