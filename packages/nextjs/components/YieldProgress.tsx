"use client";

import { motion } from "framer-motion";

interface YieldProgressProps {
  currentYield: string;
  targetAsset: string;
  progressPercent: number;
}

export function YieldProgress({ currentYield, targetAsset, progressPercent }: YieldProgressProps) {
  return (
    <div className="card">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-lg font-bold">Yield Progress</h3>
          <p className="text-gray-400 text-sm">Toward next {targetAsset} fraction</p>
        </div>
        <div className="text-right">
          <span className="text-2xl font-bold text-gradient">{progressPercent}%</span>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="progress-bar mb-4">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${progressPercent}%` }}
          transition={{ duration: 1, ease: "easeOut" }}
          className="progress-bar-fill"
        />
      </div>

      {/* Progress Details */}
      <div className="grid grid-cols-3 gap-4 text-center">
        <div>
          <div className="text-sm text-gray-400">Current Yield</div>
          <div className="font-mono text-mantle-400">{currentYield} mETH</div>
        </div>
        <div>
          <div className="text-sm text-gray-400">Fraction Price</div>
          <div className="font-mono">0.01 ETH</div>
        </div>
        <div>
          <div className="text-sm text-gray-400">Remaining</div>
          <div className="font-mono text-brick-400">
            {(0.01 - parseFloat(currentYield)).toFixed(4)} ETH
          </div>
        </div>
      </div>

      {/* Visual Progress Steps */}
      <div className="mt-6 flex items-center justify-between">
        {[0, 25, 50, 75, 100].map((milestone) => (
          <div key={milestone} className="flex flex-col items-center">
            <div
              className={`w-4 h-4 rounded-full border-2 transition-colors ${
                progressPercent >= milestone
                  ? "bg-mantle-500 border-mantle-400"
                  : "bg-dark-700 border-dark-600"
              }`}
            />
            <span className="text-xs text-gray-500 mt-1">{milestone}%</span>
          </div>
        ))}
      </div>
    </div>
  );
}
