"use client";

import { motion } from "framer-motion";
import { ConnectButton } from "@rainbow-me/rainbowkit";

export function Hero() {
  return (
    <div className="min-h-[90vh] flex flex-col items-center justify-center px-6">
      {/* Main Hero */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        className="text-center max-w-4xl"
      >
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ delay: 0.2, duration: 0.5 }}
          className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-dark-800/50 border border-dark-600 mb-8"
        >
          <span className="w-2 h-2 rounded-full bg-mantle-400 animate-pulse" />
          <span className="text-sm text-gray-400">Built on Mantle Network</span>
        </motion.div>

        <h1 className="text-5xl md:text-7xl font-bold leading-tight mb-6">
          Build <span className="glow-text">Real Wealth</span>
          <br />
          From Your Yield
        </h1>

        <p className="text-xl text-gray-400 mb-10 max-w-2xl mx-auto">
          Stake mETH on Mantle, automatically convert your yield into fractionalized 
          Real World Assets. Your principal stays <span className="text-mantle-400 font-semibold">100% safe</span>.
        </p>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <ConnectButton />
          <a href="#how-it-works" className="btn-secondary">
            Learn More →
          </a>
        </div>
      </motion.div>

      {/* Stats Banner */}
      <motion.div
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6, duration: 0.8 }}
        className="grid grid-cols-2 md:grid-cols-4 gap-6 mt-20 w-full max-w-4xl"
      >
        {[
          { label: "TVL", value: "$12.4M", icon: "💰" },
          { label: "RWAs Purchased", value: "$2.1M", icon: "🏠" },
          { label: "Avg. APY", value: "4.5%", icon: "📈" },
          { label: "Users", value: "1,247", icon: "👥" },
        ].map((stat, i) => (
          <motion.div
            key={stat.label}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.8 + i * 0.1, duration: 0.5 }}
            className="card text-center"
          >
            <span className="text-2xl mb-2 block">{stat.icon}</span>
            <div className="stat-value text-gradient">{stat.value}</div>
            <div className="stat-label">{stat.label}</div>
          </motion.div>
        ))}
      </motion.div>

      {/* How it Works Section */}
      <section id="how-it-works" className="mt-32 w-full max-w-6xl">
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl font-bold mb-4">How It Works</h2>
          <p className="text-gray-400 max-w-2xl mx-auto">
            Three simple steps to start building real wealth with your yield
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-8">
          {[
            {
              step: "01",
              title: "Stake mETH",
              description:
                "Deposit your mETH into the Strata vault. Your principal is always safe and withdrawable.",
              icon: "🔒",
            },
            {
              step: "02",
              title: "Yield Accrues",
              description:
                "Your mETH earns yield automatically. Watch your progress toward your next RWA purchase.",
              icon: "📊",
            },
            {
              step: "03",
              title: "Own Real Assets",
              description:
                "Yield is converted to fractionalized real estate, bonds, and more. Build a diversified portfolio.",
              icon: "🏠",
            },
          ].map((item, i) => (
            <motion.div
              key={item.step}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.2, duration: 0.6 }}
              viewport={{ once: true }}
              className="card-glow relative overflow-hidden group"
            >
              <div className="absolute top-0 right-0 text-8xl font-bold text-dark-700/50 -translate-y-4 translate-x-4 group-hover:text-mantle-500/20 transition-colors">
                {item.step}
              </div>
              <span className="text-4xl mb-4 block">{item.icon}</span>
              <h3 className="text-xl font-bold mb-2">{item.title}</h3>
              <p className="text-gray-400">{item.description}</p>
            </motion.div>
          ))}
        </div>
      </section>

      {/* Assets Section */}
      <section id="assets" className="mt-32 w-full max-w-6xl">
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl font-bold mb-4">Available Assets</h2>
          <p className="text-gray-400 max-w-2xl mx-auto">
            Diversified Real World Assets for every risk profile
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 gap-6">
          {[
            {
              name: "NYC Real Estate",
              symbol: "NYC-RE",
              apy: "4.5%",
              price: "0.01 ETH",
              description: "Premium Manhattan commercial property",
              icon: "🏙️",
              color: "from-blue-500/20 to-purple-500/20",
            },
            {
              name: "Treasury Bonds",
              symbol: "TBOND",
              apy: "5.25%",
              price: "0.001 ETH",
              description: "US Government-backed securities",
              icon: "📜",
              color: "from-green-500/20 to-emerald-500/20",
            },
            {
              name: "Invoice Financing",
              symbol: "INVFIN",
              apy: "8.5%",
              price: "0.005 ETH",
              description: "Fortune 500 commercial receivables",
              icon: "📑",
              color: "from-orange-500/20 to-red-500/20",
            },
            {
              name: "Green Infrastructure",
              symbol: "INFRA",
              apy: "6.5%",
              price: "0.002 ETH",
              description: "Solar and wind farm financing",
              icon: "🌱",
              color: "from-mantle-500/20 to-cyan-500/20",
            },
          ].map((asset, i) => (
            <motion.div
              key={asset.symbol}
              initial={{ opacity: 0, x: i % 2 === 0 ? -30 : 30 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.1, duration: 0.6 }}
              viewport={{ once: true }}
              className={`card-glow bg-gradient-to-br ${asset.color} relative overflow-hidden`}
            >
              <div className="flex items-start justify-between">
                <div>
                  <span className="text-3xl mb-2 block">{asset.icon}</span>
                  <h3 className="text-xl font-bold">{asset.name}</h3>
                  <span className="asset-badge mt-2">{asset.symbol}</span>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-mantle-400">{asset.apy}</div>
                  <div className="text-sm text-gray-400">APY</div>
                </div>
              </div>
              <p className="text-gray-400 mt-4">{asset.description}</p>
              <div className="flex items-center justify-between mt-4 pt-4 border-t border-dark-600/50">
                <span className="text-sm text-gray-500">Price per fraction</span>
                <span className="font-mono text-mantle-400">{asset.price}</span>
              </div>
            </motion.div>
          ))}
        </div>
      </section>
    </div>
  );
}
