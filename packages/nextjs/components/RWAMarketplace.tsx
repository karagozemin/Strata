"use client";

import { motion } from "framer-motion";
import { useState } from "react";
import { useAllAssets, useRWAToken, type RWAAsset } from "../hooks";

// Asset icons/emojis for visual representation
const ASSET_ICONS: Record<number, string> = {
  1: "🏙️", // NYC Real Estate
  2: "📜", // Treasury Bonds
  3: "📋", // Invoice Financing
  4: "🌱", // Green Infrastructure
};

// Asset colors for styling
const ASSET_COLORS: Record<number, string> = {
  1: "from-blue-500/20 to-purple-500/20 border-blue-500/30",
  2: "from-green-500/20 to-emerald-500/20 border-green-500/30",
  3: "from-orange-500/20 to-yellow-500/20 border-orange-500/30",
  4: "from-teal-500/20 to-cyan-500/20 border-teal-500/30",
};

interface AssetCardProps {
  asset: RWAAsset;
  isSelected: boolean;
  onSelect: () => void;
  userBalance?: number;
}

function AssetCard({ asset, isSelected, onSelect, userBalance = 0 }: AssetCardProps) {
  return (
    <motion.button
      onClick={onSelect}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      className={`w-full p-6 rounded-2xl text-left transition-all border ${
        isSelected
          ? "bg-gradient-to-br " + ASSET_COLORS[asset.id] + " ring-2 ring-mantle-400"
          : "bg-dark-800 border-dark-600 hover:border-dark-500"
      }`}
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <span className="text-4xl">{ASSET_ICONS[asset.id]}</span>
          <div>
            <h3 className="font-bold text-lg">{asset.name}</h3>
            <span className="text-sm text-gray-400">{asset.symbol}</span>
          </div>
        </div>
        {isSelected && (
          <span className="bg-mantle-500 text-white text-xs px-2 py-1 rounded-full">
            Selected
          </span>
        )}
      </div>

      {/* Description */}
      <p className="text-sm text-gray-400 mb-4 line-clamp-2">{asset.description}</p>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-4 mb-4">
        <div>
          <span className="text-xs text-gray-500 block">Price/Fraction</span>
          <span className="text-lg font-bold text-white">{asset.pricePerFraction} ETH</span>
        </div>
        <div>
          <span className="text-xs text-gray-500 block">Expected APY</span>
          <span className="text-lg font-bold text-mantle-400">{asset.apy}%</span>
        </div>
      </div>

      {/* User Balance */}
      {userBalance > 0 && (
        <div className="pt-4 border-t border-dark-600">
          <div className="flex justify-between items-center">
            <span className="text-sm text-gray-400">You Own</span>
            <span className="font-bold text-brick-400">{userBalance} fractions</span>
          </div>
          <div className="flex justify-between items-center mt-1">
            <span className="text-sm text-gray-400">Value</span>
            <span className="font-medium text-white">
              {(userBalance * parseFloat(asset.pricePerFraction)).toFixed(4)} ETH
            </span>
          </div>
        </div>
      )}

      {/* Active Status */}
      <div className="mt-4 flex items-center gap-2">
        <span
          className={`w-2 h-2 rounded-full ${
            asset.isActive ? "bg-green-400" : "bg-red-400"
          }`}
        />
        <span className="text-xs text-gray-400">
          {asset.isActive ? "Active - Available for purchase" : "Inactive"}
        </span>
      </div>
    </motion.button>
  );
}

export function RWAMarketplace() {
  const { assets, isLoading: assetsLoading } = useAllAssets();
  const { portfolio, totalPortfolioValue, isLoading: portfolioLoading } = useRWAToken();
  const [selectedAsset, setSelectedAsset] = useState<number | null>(null);

  // Get user balance for each asset
  const getAssetBalance = (assetId: number): number => {
    const item = portfolio.find((p) => p.assetId === assetId);
    return item?.balance || 0;
  };

  const selectedAssetData = assets.find((a) => a.id === selectedAsset);

  if (assetsLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-mantle-400"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold">RWA Marketplace</h2>
          <p className="text-gray-400">Browse and select assets for yield-based purchases</p>
        </div>
        <div className="text-right">
          <span className="text-sm text-gray-400 block">Your Portfolio Value</span>
          <span className="text-xl font-bold text-gradient">{totalPortfolioValue} ETH</span>
        </div>
      </div>

      {/* Asset Grid */}
      <div className="grid md:grid-cols-2 gap-4">
        {assets.map((asset) => (
          <AssetCard
            key={asset.id}
            asset={asset}
            isSelected={selectedAsset === asset.id}
            onSelect={() => setSelectedAsset(asset.id === selectedAsset ? null : asset.id)}
            userBalance={getAssetBalance(asset.id)}
          />
        ))}
      </div>

      {/* Selected Asset Details */}
      {selectedAssetData && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="card bg-gradient-to-br from-dark-800 to-dark-900"
        >
          <div className="flex items-center gap-4 mb-6">
            <span className="text-5xl">{ASSET_ICONS[selectedAssetData.id]}</span>
            <div>
              <h3 className="text-xl font-bold">{selectedAssetData.name}</h3>
              <p className="text-gray-400">{selectedAssetData.symbol}</p>
            </div>
          </div>

          <p className="text-gray-300 mb-6">{selectedAssetData.description}</p>

          {/* Detailed Stats */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <div className="bg-dark-700/50 rounded-xl p-4">
              <span className="text-xs text-gray-500 block mb-1">Price/Fraction</span>
              <span className="text-lg font-bold">{selectedAssetData.pricePerFraction} ETH</span>
            </div>
            <div className="bg-dark-700/50 rounded-xl p-4">
              <span className="text-xs text-gray-500 block mb-1">Total Value</span>
              <span className="text-lg font-bold">{selectedAssetData.totalValue} ETH</span>
            </div>
            <div className="bg-dark-700/50 rounded-xl p-4">
              <span className="text-xs text-gray-500 block mb-1">Total Fractions</span>
              <span className="text-lg font-bold">
                {selectedAssetData.totalFractions.toLocaleString()}
              </span>
            </div>
            <div className="bg-dark-700/50 rounded-xl p-4">
              <span className="text-xs text-gray-500 block mb-1">Expected APY</span>
              <span className="text-lg font-bold text-mantle-400">{selectedAssetData.apy}%</span>
            </div>
          </div>

          {/* Mantle DA Reference */}
          <div className="bg-dark-700/30 rounded-xl p-4 mb-6">
            <div className="flex items-center gap-2 mb-2">
              <span className="text-mantle-400">📄</span>
              <span className="text-sm font-medium">Legal Documents (Mantle DA)</span>
            </div>
            <code className="text-xs text-gray-400 break-all">{selectedAssetData.mantleDARef}</code>
          </div>

          {/* Action Button */}
          <button className="btn-primary w-full">
            Set as Target Asset for Yield Purchases
          </button>
        </motion.div>
      )}

      {/* Info Card */}
      <div className="card bg-dark-800/50 border border-dark-600">
        <div className="flex items-start gap-4">
          <span className="text-3xl">💡</span>
          <div>
            <h4 className="font-bold mb-2">How RWA Purchases Work</h4>
            <p className="text-gray-400 text-sm">
              Select a target asset above. When you deposit mETH into the vault, your yield will
              automatically be used to purchase fractions of your selected RWA. You can change your
              target asset at any time, and your existing RWA holdings remain in your portfolio.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default RWAMarketplace;
