// =============================================================================
// useRWAToken.ts - Custom Hook for RealWorldAsset Contract Interactions
// Strata - Mantle Global Hackathon 2025
// =============================================================================

import { useAccount, useChainId, useReadContract } from "wagmi";
import { formatEther } from "viem";
import { RWA_TOKEN_ABI } from "../contracts/abis";
import { getContractAddresses } from "../contracts/addresses";

// Asset type definition
export interface RWAAsset {
  id: number;
  name: string;
  symbol: string;
  description: string;
  pricePerFraction: string;
  totalValue: string;
  totalFractions: number;
  mantleDARef: string;
  imageURI: string;
  isActive: boolean;
  apy: number;
}

// Portfolio item definition
export interface PortfolioItem {
  assetId: number;
  balance: number;
  value: string;
  asset?: RWAAsset;
}

/**
 * Custom hook for interacting with the RealWorldAsset ERC-1155 contract
 * Provides asset information and portfolio data
 */
export function useRWAToken() {
  const { address } = useAccount();
  const chainId = useChainId();
  const contracts = getContractAddresses(chainId);

  // =========================================================================
  // GET ALL ASSET IDS
  // =========================================================================

  const { data: assetIds, refetch: refetchAssetIds } = useReadContract({
    address: contracts.rwaToken,
    abi: RWA_TOKEN_ABI,
    functionName: "getAllAssetIds",
    query: {
      enabled: true,
    },
  });

  // =========================================================================
  // GET USER PORTFOLIO
  // =========================================================================

  const { data: portfolioData, refetch: refetchPortfolio, isLoading: isPortfolioLoading } = useReadContract({
    address: contracts.rwaToken,
    abi: RWA_TOKEN_ABI,
    functionName: "getUserPortfolio",
    args: address ? [address] : undefined,
    query: {
      enabled: !!address,
    },
  });

  // =========================================================================
  // FORMAT PORTFOLIO DATA
  // =========================================================================

  const portfolio: PortfolioItem[] = portfolioData
    ? (portfolioData[0] as bigint[]).map((assetId, index) => ({
        assetId: Number(assetId),
        balance: Number((portfolioData[1] as bigint[])[index]),
        value: formatEther((portfolioData[2] as bigint[])[index]),
      }))
    : [];

  // Filter to only show assets user owns
  const ownedAssets = portfolio.filter((item) => item.balance > 0);

  // Calculate total portfolio value
  const totalPortfolioValue = portfolio.reduce(
    (sum, item) => sum + parseFloat(item.value),
    0
  );

  // =========================================================================
  // RETURN HOOK DATA
  // =========================================================================

  return {
    // Asset IDs
    assetIds: assetIds ? (assetIds as bigint[]).map(Number) : [],

    // Portfolio data
    portfolio,
    ownedAssets,
    totalPortfolioValue: totalPortfolioValue.toFixed(6),

    // Loading states
    isLoading: isPortfolioLoading,

    // Refetch functions
    refetch: () => {
      refetchAssetIds();
      refetchPortfolio();
    },
  };
}

/**
 * Hook for getting information about a specific asset
 */
export function useAssetInfo(assetId: number) {
  const chainId = useChainId();
  const contracts = getContractAddresses(chainId);

  const { data: assetInfo, isLoading } = useReadContract({
    address: contracts.rwaToken,
    abi: RWA_TOKEN_ABI,
    functionName: "getAssetInfo",
    args: [BigInt(assetId)],
    query: {
      enabled: assetId > 0,
    },
  });

  const formattedAsset: RWAAsset | null = assetInfo
    ? {
        id: assetId,
        name: (assetInfo as any).name,
        symbol: (assetInfo as any).symbol,
        description: (assetInfo as any).description,
        pricePerFraction: formatEther((assetInfo as any).pricePerFraction),
        totalValue: formatEther((assetInfo as any).totalValue),
        totalFractions: Number((assetInfo as any).totalFractions),
        mantleDARef: (assetInfo as any).mantleDARef,
        imageURI: (assetInfo as any).imageURI,
        isActive: (assetInfo as any).isActive,
        apy: Number((assetInfo as any).apy) / 100, // Convert bps to percent
      }
    : null;

  return {
    asset: formattedAsset,
    isLoading,
  };
}

/**
 * Hook for getting all available RWA assets with their info
 */
export function useAllAssets() {
  const chainId = useChainId();
  const contracts = getContractAddresses(chainId);

  // Get asset 1 (NYC Real Estate)
  const { data: asset1 } = useReadContract({
    address: contracts.rwaToken,
    abi: RWA_TOKEN_ABI,
    functionName: "getAssetInfo",
    args: [BigInt(1)],
  });

  // Get asset 2 (Treasury Bonds)
  const { data: asset2 } = useReadContract({
    address: contracts.rwaToken,
    abi: RWA_TOKEN_ABI,
    functionName: "getAssetInfo",
    args: [BigInt(2)],
  });

  // Get asset 3 (Invoice Financing)
  const { data: asset3 } = useReadContract({
    address: contracts.rwaToken,
    abi: RWA_TOKEN_ABI,
    functionName: "getAssetInfo",
    args: [BigInt(3)],
  });

  // Get asset 4 (Infrastructure)
  const { data: asset4 } = useReadContract({
    address: contracts.rwaToken,
    abi: RWA_TOKEN_ABI,
    functionName: "getAssetInfo",
    args: [BigInt(4)],
  });

  const formatAsset = (data: any, id: number): RWAAsset | null => {
    if (!data) return null;
    return {
      id,
      name: data.name,
      symbol: data.symbol,
      description: data.description,
      pricePerFraction: formatEther(data.pricePerFraction),
      totalValue: formatEther(data.totalValue),
      totalFractions: Number(data.totalFractions),
      mantleDARef: data.mantleDARef,
      imageURI: data.imageURI,
      isActive: data.isActive,
      apy: Number(data.apy) / 100,
    };
  };

  const assets: RWAAsset[] = [
    formatAsset(asset1, 1),
    formatAsset(asset2, 2),
    formatAsset(asset3, 3),
    formatAsset(asset4, 4),
  ].filter((a): a is RWAAsset => a !== null);

  return {
    assets,
    isLoading: !asset1 && !asset2 && !asset3 && !asset4,
  };
}

/**
 * Hook for getting user's balance of a specific asset
 */
export function useAssetBalance(assetId: number) {
  const { address } = useAccount();
  const chainId = useChainId();
  const contracts = getContractAddresses(chainId);

  const { data: balance, refetch } = useReadContract({
    address: contracts.rwaToken,
    abi: RWA_TOKEN_ABI,
    functionName: "balanceOf",
    args: address ? [address, BigInt(assetId)] : undefined,
    query: {
      enabled: !!address && assetId > 0,
    },
  });

  return {
    balance: balance ? Number(balance) : 0,
    refetch,
  };
}
