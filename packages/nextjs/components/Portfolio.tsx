"use client";

import { motion } from "framer-motion";

// Mock portfolio data
const MOCK_PORTFOLIO = [
  {
    id: 1,
    name: "NYC Real Estate",
    symbol: "NYC-RE",
    fractions: 12,
    value: "0.12",
    apy: "4.5%",
    icon: "🏙️",
  },
  {
    id: 2,
    name: "Treasury Bonds",
    symbol: "TBOND",
    fractions: 45,
    value: "0.045",
    apy: "5.25%",
    icon: "📜",
  },
  {
    id: 3,
    name: "Invoice Financing",
    symbol: "INVFIN",
    fractions: 8,
    value: "0.04",
    apy: "8.5%",
    icon: "📑",
  },
];

export function Portfolio() {
  const totalValue = MOCK_PORTFOLIO.reduce(
    (sum, asset) => sum + parseFloat(asset.value),
    0
  ).toFixed(4);

  return (
    <div className="space-y-6">
      {/* Portfolio Summary */}
      <div className="card bg-gradient-to-br from-brick-500/10 to-mantle-500/10">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-bold mb-1">Your RWA Portfolio</h3>
            <p className="text-gray-400 text-sm">
              {MOCK_PORTFOLIO.length} asset types · {MOCK_PORTFOLIO.reduce((sum, a) => sum + a.fractions, 0)} total fractions
            </p>
          </div>
          <div className="text-right">
            <div className="text-3xl font-bold text-gradient">{totalValue} ETH</div>
            <div className="text-sm text-gray-400">Total Value</div>
          </div>
        </div>
      </div>

      {/* Asset List */}
      <div className="space-y-4">
        {MOCK_PORTFOLIO.map((asset, i) => (
          <motion.div
            key={asset.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            className="card hover:border-mantle-500/30 transition-colors cursor-pointer"
          >
            <div className="flex items-center gap-4">
              {/* Asset Icon */}
              <div className="w-14 h-14 rounded-xl bg-dark-700 flex items-center justify-center text-3xl">
                {asset.icon}
              </div>

              {/* Asset Info */}
              <div className="flex-1">
                <div className="flex items-center gap-2">
                  <h4 className="font-bold">{asset.name}</h4>
                  <span className="asset-badge text-xs">{asset.symbol}</span>
                </div>
                <div className="text-gray-400 text-sm mt-1">
                  {asset.fractions} fractions · {asset.apy} APY
                </div>
              </div>

              {/* Value */}
              <div className="text-right">
                <div className="font-mono text-lg">{asset.value} ETH</div>
                <div className="text-sm text-mantle-400">
                  +{(parseFloat(asset.value) * parseFloat(asset.apy) / 100).toFixed(4)} /yr
                </div>
              </div>
            </div>

            {/* Progress Bar (how much of this asset they own) */}
            <div className="mt-4 pt-4 border-t border-dark-600/50">
              <div className="flex justify-between text-sm text-gray-400 mb-2">
                <span>Ownership Progress</span>
                <span>{((asset.fractions / 1000000) * 100).toFixed(4)}%</span>
              </div>
              <div className="progress-bar">
                <div
                  className="progress-bar-fill"
                  style={{ width: `${Math.min((asset.fractions / 100) * 100, 100)}%` }}
                />
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Empty State (when no portfolio) */}
      {MOCK_PORTFOLIO.length === 0 && (
        <div className="card text-center py-12">
          <span className="text-6xl mb-4 block">🏠</span>
          <h3 className="text-xl font-bold mb-2">No RWAs Yet</h3>
          <p className="text-gray-400 mb-6">
            Start by depositing mETH and let your yield work for you
          </p>
          <button className="btn-primary">Deposit Now</button>
        </div>
      )}

      {/* Portfolio Actions */}
      <div className="grid grid-cols-2 gap-4">
        <button className="btn-secondary">
          📊 View Details
        </button>
        <button className="btn-secondary">
          📄 Export Report
        </button>
      </div>
    </div>
  );
}
