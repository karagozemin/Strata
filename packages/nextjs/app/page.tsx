"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import { Dashboard } from "@/components/Dashboard";
import { Hero } from "@/components/Hero";

export default function Home() {
  const { isConnected } = useAccount();

  return (
    <main className="min-h-screen bg-mesh bg-grid-pattern">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 backdrop-blur-xl bg-dark-900/80 border-b border-dark-600/50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-brick-500 to-mantle-500 flex items-center justify-center">
              <span className="text-xl">🏗️</span>
            </div>
            <span className="text-xl font-bold">
              Yield<span className="text-gradient">Brick</span>
            </span>
          </div>

          <div className="flex items-center gap-6">
            <a href="#how-it-works" className="text-gray-400 hover:text-white transition-colors">
              How it Works
            </a>
            <a href="#assets" className="text-gray-400 hover:text-white transition-colors">
              Assets
            </a>
            <ConnectButton />
          </div>
        </div>
      </nav>

      {/* Content */}
      <div className="pt-20">
        {isConnected ? <Dashboard /> : <Hero />}
      </div>

      {/* Footer */}
      <footer className="border-t border-dark-600/50 py-8 mt-20">
        <div className="max-w-7xl mx-auto px-6 flex items-center justify-between text-sm text-gray-500">
          <div>Built on Mantle Network 🌐</div>
          <div>Mantle Global Hackathon 2025</div>
        </div>
      </footer>
    </main>
  );
}
