"use client";

import { motion } from "framer-motion";
import { useState } from "react";
import { useAccount } from "wagmi";
import { YieldProgress } from "./YieldProgress";
import { Portfolio } from "./Portfolio";
import { RWAMarketplace } from "./RWAMarketplace";
import { useYieldVault, useMETH } from "../hooks";

// Asset names mapping
const ASSET_NAMES: Record<number, string> = {
  1: "NYC Real Estate",
  2: "Treasury Bonds",
  3: "Invoice Financing",
  4: "Infrastructure",
};

export function Dashboard() {
  const { address } = useAccount();
  const [depositAmount, setDepositAmount] = useState("");
  const [activeTab, setActiveTab] = useState<"deposit" | "portfolio" | "marketplace">("deposit");

  // Use custom hooks for contract interactions
  const {
    dashboard,
    yieldProgress,
    protocolStats,
    isLoading,
    isWritePending,
    isConfirming,
    deposit,
    harvestAndBuy,
    mockYield,
    refetch,
  } = useYieldVault();

  const { balance: mETHBalance, approve, approveMax, isPending: isApproving } = useMETH();

  // Fallback data for when contracts aren't deployed
  const displayData = dashboard || {
    principal: "0",
    pendingYield: "0",
    totalHarvested: "0",
    rwaValue: "0",
    targetAssetId: 1,
  };

  const displayProgress = yieldProgress || {
    progressPercent: 0,
  };

  const displayStats = protocolStats || {
    totalDeposits: "0",
    totalUsers: 0,
    protocolYield: "0",
    rwaValue: "0",
  };

  // Handlers
  const handleDeposit = async () => {
    if (!depositAmount) return;
    try {
      await approveMax();
      await deposit(depositAmount);
      setDepositAmount("");
      refetch();
    } catch (error) {
      console.error("Deposit failed:", error);
    }
  };

  const handleHarvest = async () => {
    try {
      await harvestAndBuy();
      refetch();
    } catch (error) {
      console.error("Harvest failed:", error);
    }
  };

  const handleMockYield = async () => {
    try {
      await mockYield("0.01");
      refetch();
    } catch (error) {
      console.error("Mock yield failed:", error);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      {/* Welcome Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-8"
      >
        <h1 className="text-3xl font-bold mb-2">
          Welcome back, <span className="text-gradient">{address?.slice(0, 8)}...</span>
        </h1>
        <p className="text-gray-400">Your yield is working hard to build real wealth</p>
        {mETHBalance && parseFloat(mETHBalance) > 0 && (
          <p className="text-sm text-mantle-400 mt-1">Balance: {parseFloat(mETHBalance).toFixed(4)} mETH</p>
        )}
      </motion.div>

      {/* Stats Overview */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8"
      >
        <div className="stat-card">
          <span className="stat-label">Principal Staked</span>
          <span className="stat-value text-white">{parseFloat(displayData.principal).toFixed(4)} mETH</span>
        </div>
        <div className="stat-card">
          <span className="stat-label">Pending Yield</span>
          <span className="stat-value text-mantle-400">{parseFloat(displayData.pendingYield).toFixed(6)} mETH</span>
        </div>
        <div className="stat-card">
          <span className="stat-label">Total Harvested</span>
          <span className="stat-value text-brick-400">{parseFloat(displayData.totalHarvested).toFixed(4)} mETH</span>
        </div>
        <div className="stat-card">
          <span className="stat-label">RWA Value</span>
          <span className="stat-value text-gradient">{parseFloat(displayData.rwaValue).toFixed(4)} ETH</span>
        </div>
      </motion.div>

      {/* Main Content Grid */}
      <div className="grid lg:grid-cols-3 gap-8">
        {/* Left Column - Actions */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.2 }}
          className="lg:col-span-2 space-y-6"
        >
          {/* Tab Navigation */}
          <div className="flex gap-2 p-1 bg-dark-800 rounded-xl">
            <button
              onClick={() => setActiveTab("deposit")}
              className={`flex-1 py-3 rounded-lg font-medium transition-all ${
                activeTab === "deposit"
                  ? "bg-dark-600 text-white"
                  : "text-gray-400 hover:text-white"
              }`}
            >
              Deposit & Harvest
            </button>
            <button
              onClick={() => setActiveTab("portfolio")}
              className={`flex-1 py-3 rounded-lg font-medium transition-all ${
                activeTab === "portfolio"
                  ? "bg-dark-600 text-white"
                  : "text-gray-400 hover:text-white"
              }`}
            >
              RWA Portfolio
            </button>
            <button
              onClick={() => setActiveTab("marketplace")}
              className={`flex-1 py-3 rounded-lg font-medium transition-all ${
                activeTab === "marketplace"
                  ? "bg-dark-600 text-white"
                  : "text-gray-400 hover:text-white"
              }`}
            >
              Marketplace
            </button>
          </div>

          {activeTab === "deposit" ? (
            <div className="space-y-6">
              {/* Deposit Card */}
              <div className="card">
                <h3 className="text-lg font-bold mb-4">Deposit mETH</h3>
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm text-gray-400 mb-2">Amount</label>
                    <div className="relative">
                      <input
                        type="number"
                        value={depositAmount}
                        onChange={(e) => setDepositAmount(e.target.value)}
                        placeholder="0.0"
                        className="input-field pr-20"
                      />
                      <button
                        className="absolute right-2 top-1/2 -translate-y-1/2 px-3 py-1 text-sm text-mantle-400 hover:bg-dark-600 rounded-lg transition-colors"
                        onClick={() => setDepositAmount(mETHBalance || "10")}
                      >
                        MAX
                      </button>
                    </div>
                  </div>
                  <button 
                    className="btn-primary w-full disabled:opacity-50"
                    onClick={handleDeposit}
                    disabled={isWritePending || isConfirming || isApproving || !depositAmount}
                  >
                    {isApproving ? "Approving..." : isWritePending ? "Depositing..." : isConfirming ? "Confirming..." : "Deposit mETH"}
                  </button>
                </div>
              </div>

              {/* Yield Progress */}
              <YieldProgress
                currentYield={displayData.pendingYield}
                targetAsset={ASSET_NAMES[displayData.targetAssetId] || "NYC Real Estate"}
                progressPercent={displayProgress.progressPercent}
              />

              {/* Harvest Card */}
              <div className="card bg-gradient-to-br from-mantle-500/10 to-brick-500/10">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h3 className="text-lg font-bold">Ready to Harvest</h3>
                    <p className="text-gray-400 text-sm">
                      Convert {parseFloat(displayData.pendingYield).toFixed(6)} mETH yield to RWA
                    </p>
                  </div>
                  <span className="text-4xl">🌾</span>
                </div>
                <button 
                  className="btn-primary w-full disabled:opacity-50"
                  onClick={handleHarvest}
                  disabled={isWritePending || isConfirming || parseFloat(displayData.pendingYield) === 0}
                >
                  {isWritePending || isConfirming ? "Processing..." : "Harvest & Buy RWA"}
                </button>
              </div>
            </div>
          ) : activeTab === "portfolio" ? (
            <Portfolio />
          ) : (
            <RWAMarketplace />
          )}
        </motion.div>

        {/* Right Column - Info */}
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.3 }}
          className="space-y-6"
        >
          {/* Target Asset Selection */}
          <div className="card">
            <h3 className="text-lg font-bold mb-4">Target Asset</h3>
            <p className="text-gray-400 text-sm mb-4">
              Select which RWA your yield purchases
            </p>
            <div className="space-y-2">
              {[
                { id: 1, name: "NYC Real Estate", apy: "4.5%" },
                { id: 2, name: "Treasury Bonds", apy: "5.25%" },
                { id: 3, name: "Invoice Financing", apy: "8.5%" },
                { id: 4, name: "Infrastructure", apy: "6.5%" },
              ].map((asset) => (
                <button
                  key={asset.id}
                  className={`w-full p-3 rounded-xl flex items-center justify-between transition-all ${
                    asset.id === 1
                      ? "bg-mantle-500/20 border border-mantle-500/50"
                      : "bg-dark-700 border border-dark-600 hover:border-dark-500"
                  }`}
                >
                  <span>{asset.name}</span>
                  <span className="text-mantle-400">{asset.apy}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Protocol Stats */}
          <div className="card">
            <h3 className="text-lg font-bold mb-4">Protocol Stats</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-400">Total Value Locked</span>
                <span className="font-mono">{parseFloat(displayStats.totalDeposits).toFixed(2)} mETH</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Total Users</span>
                <span className="font-mono">{displayStats.totalUsers}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Yield Harvested</span>
                <span className="font-mono text-mantle-400">{parseFloat(displayStats.protocolYield).toFixed(4)} mETH</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">RWA Purchased</span>
                <span className="font-mono text-brick-400">{parseFloat(displayStats.rwaValue).toFixed(4)} ETH</span>
              </div>
            </div>
          </div>

          {/* Demo Controls */}
          <div className="card border-dashed border-yellow-500/30">
            <div className="flex items-center gap-2 mb-4">
              <span className="text-yellow-500">⚠️</span>
              <h3 className="font-bold text-yellow-500">Demo Controls</h3>
            </div>
            <p className="text-gray-400 text-sm mb-4">
              Simulate yield generation for hackathon demo
            </p>
            <button 
              className="btn-secondary w-full mb-2"
              onClick={() => {/* TODO: Implement faucet */}}
            >
              🚰 Get Test mETH
            </button>
            <button 
              className="btn-secondary w-full disabled:opacity-50"
              onClick={handleMockYield}
              disabled={isWritePending || isConfirming}
            >
              {isWritePending || isConfirming ? "Processing..." : "⚡ Generate Mock Yield"}
            </button>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
