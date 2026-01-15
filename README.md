# Accrue

<p align="center">
  <img src="packages/nextjs/public/logo.png" alt="Accrue Logo" width="180"/>
</p>

<h3 align="center">Yield-Collateralized RWA Purchasing Protocol</h3>

<p align="center">
  <strong>Build Real Wealth From Your Yield</strong>
</p>

<p align="center">
  <a href="https://mantle.xyz"><img src="https://img.shields.io/badge/Built%20on-Mantle-00D9A4?style=for-the-badge" alt="Built on Mantle"/></a>
  <a href="https://soliditylang.org"><img src="https://img.shields.io/badge/Solidity-0.8.24-363636?style=for-the-badge" alt="Solidity"/></a>
  <a href="https://nextjs.org"><img src="https://img.shields.io/badge/Next.js-14-black?style=for-the-badge" alt="Next.js"/></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License: MIT"/></a>
</p>

<p align="center">
  <b>🏆 Mantle Global Hackathon 2025 - RWA/RealFi Track</b>
</p>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [The Problem](#-the-problem)
- [The Solution](#-the-solution)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Smart Contracts](#-smart-contracts)
- [Tech Stack](#-tech-stack)
- [Quick Start](#-quick-start)
- [Deployment](#-deployment)
- [Contract Addresses](#-contract-addresses)
- [Demo Flow](#-demo-flow)
- [Testing](#-testing)
- [Security](#-security)
- [Roadmap](#-roadmap)
- [License](#-license)

---

## 🌟 Overview

**Accrue** is a DeFi protocol that automatically converts your mETH staking yield into fractionalized Real World Assets (RWAs). Built on Mantle Network, it enables passive accumulation of tokenized real estate, bonds, and infrastructure investments—while keeping your principal 100% safe.

> 💡 **TL;DR**: Deposit mETH → Earn yield → Yield auto-converts to real-world assets → Build wealth passively

---

## 🎯 The Problem

**DeFi yields are ephemeral.** Users stake their assets, earn APY, but the yield just sits there—getting swapped, spent, or slowly eroding to inflation.

Meanwhile, **Real World Assets remain inaccessible** to most crypto users due to:
- 💰 High minimum investments ($10,000+)
- 📋 Complex legal structures
- 🌍 Geographic restrictions  
- 🔒 Lack of liquidity

---

## 💡 The Solution

**Accrue** bridges DeFi yields with real-world ownership:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   💰 mETH Deposit  →  📈 Yield Generated  →  🏠 RWA Purchased              │
│                                                                             │
│   Your principal         Protocol harvests       Fractionalized assets     │
│   stays 100% safe        yield automatically     added to your portfolio   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### How It Works

1. **Deposit mETH** into the Accrue vault
2. **Select Target Asset** (Real Estate, Bonds, Invoice Financing, Infrastructure)
3. **Yield Accumulates** from mETH staking rewards
4. **Harvest & Buy** converts yield to RWA fractions automatically
5. **Build Portfolio** of real-world assets over time

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🔐 **Principal Safety** | Your deposited mETH is never at risk—only yield is used |
| 🏠 **Auto RWA Accumulation** | Yield automatically converts to real assets |
| 📊 **Diversified Portfolio** | Choose from 4 asset classes |
| ⛽ **Low Gas Costs** | Mantle L2 enables micro-transactions |
| 🔗 **On-Chain Verification** | All ownership verifiable on Mantle |
| 📱 **Modern UI** | Sleek dashboard with real-time updates |

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ACCRUE PROTOCOL                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌────────────────┐                         ┌────────────────────────────┐ │
│   │                │                         │     REAL WORLD ASSETS      │ │
│   │   User Wallet  │                         │     (ERC-1155 Tokens)      │ │
│   │                │                         │                            │ │
│   │  ┌──────────┐  │    Principal            │  🏠 NYC Real Estate        │ │
│   │  │   mETH   │──┼──────────────┐          │  📜 Treasury Bonds         │ │
│   │  │ Holdings │  │              │          │  📑 Invoice Financing      │ │
│   │  └──────────┘  │              ▼          │  🌱 Green Infrastructure   │ │
│   │                │    ┌─────────────────┐  │                            │ │
│   │  ┌──────────┐  │    │                 │  └────────────────────────────┘ │
│   │  │   RWA    │◄─┼────│   YieldVault    │                │                │
│   │  │ Fractions│  │    │   (ERC-4626)    │────────────────┘                │
│   │  └──────────┘  │    │                 │    Yield → RWA Purchase         │
│   │                │    │  ┌───────────┐  │                                 │
│   └────────────────┘    │  │  Yield    │  │  ┌────────────────────────────┐ │
│                         │  │  Tracker  │  │  │      Mantle DA             │ │
│                         │  └───────────┘  │  │   (Legal Documents)        │ │
│                         └─────────────────┘  └────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

> 📄 **For detailed technical architecture, see [ARCHITECTURE.md](ARCHITECTURE.md)**

---

## 🌐 Why Mantle?

| Feature | Mantle Advantage |
|---------|------------------|
| **$mETH Collateral** | Native yield-bearing asset (~4% APY) |
| **Low Gas Fees** | Enables frequent micro-harvests ($0.001 vs $5+ on mainnet) |
| **Mantle DA** | Stores legal documents for RWA compliance |
| **High TPS** | Real-time yield tracking and updates |

---

## 📜 Smart Contracts

### YieldVault.sol (ERC-4626)

Core vault contract managing deposits and yield-to-RWA conversion.

| Function | Description |
|----------|-------------|
| `deposit(assets, receiver)` | Deposit mETH into vault |
| `withdraw(assets, receiver, owner)` | Withdraw principal |
| `setTargetAsset(assetId)` | Choose target RWA type |
| `harvestAndBuy()` | Convert yield to RWA fractions |
| `getUserDashboard(user)` | Get user's complete stats |
| `getYieldProgress(user)` | Get yield accumulation progress |

### RealWorldAsset.sol (ERC-1155)

Multi-token contract for fractionalized RWA ownership.

| ID | Asset | Price/Fraction | APY |
|----|-------|----------------|-----|
| 1 | 🏠 NYC Real Estate | 0.01 mETH | 4.5% |
| 2 | 📜 Treasury Bonds | 0.001 mETH | 5.25% |
| 3 | 📑 Invoice Financing | 0.005 mETH | 8.5% |
| 4 | 🌱 Green Infrastructure | 0.002 mETH | 6.5% |

---

## 🛠 Tech Stack

### Smart Contracts
- **Solidity 0.8.24** - Smart contract language
- **Foundry** - Development framework
- **OpenZeppelin 5.x** - Security-audited libraries
- **ERC-4626** - Tokenized vault standard
- **ERC-1155** - Multi-token standard

### Frontend
- **Next.js 14** - React framework (App Router)
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **Framer Motion** - Animations
- **Wagmi v2** - React hooks for Ethereum
- **Viem** - TypeScript Ethereum library
- **RainbowKit v2** - Wallet connection
- **react-hot-toast** - Notifications

---

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- [Foundry](https://getfoundry.sh/) installed
- Wallet with testnet MNT ([Mantle Faucet](https://faucet.sepolia.mantle.xyz/))

### 1. Clone & Install

```bash
git clone https://github.com/karagozemin/Accrue
cd Accrue

# Install frontend dependencies
cd packages/nextjs
npm install

# Install contract dependencies
cd ../foundry
forge install
```

### 2. Configure Environment

```bash
# Foundry (.env)
cp env-example.txt .env
# Edit with your private key
```

### 3. Build & Test

```bash
# Run contract tests
cd packages/foundry
forge test -vvv

# Start frontend
cd ../nextjs
npm run dev
```

### 4. Open App

Navigate to `http://localhost:3000`

---

## 📦 Deployment

### Deploy to Mantle Sepolia

```bash
cd packages/foundry

forge script script/Deploy.s.sol:DeployAccrue \
  --rpc-url https://rpc.sepolia.mantle.xyz \
  --broadcast \
  --verify \
  -vvvv
```

### Verify Contracts

```bash
forge verify-contract <ADDRESS> src/YieldVault.sol:YieldVault \
  --chain-id 5003 \
  --verifier-url https://api.sepolia.mantlescan.xyz/api
```

---

## 📍 Contract Addresses

### Mantle Sepolia Testnet (Chain ID: 5003)

| Contract | Address | Explorer |
|----------|---------|----------|
| **MockMETH** | `0xB7Ab966115aF7d21E7Aa6e31A9AdfC92291092E0` | [View](https://sepolia.mantlescan.xyz/address/0xB7Ab966115aF7d21E7Aa6e31A9AdfC92291092E0) |
| **RealWorldAsset** | `0xa520c7Aa947f3B610d274377D261Eb5AcD70883F` | [View](https://sepolia.mantlescan.xyz/address/0xa520c7Aa947f3B610d274377D261Eb5AcD70883F) |
| **YieldVault** | `0x9C70C2F67028e5464F5b60E29648240e358E83B6` | [View](https://sepolia.mantlescan.xyz/address/0x9C70C2F67028e5464F5b60E29648240e358E83B6) |

---

## 🎮 Demo Flow

```
1. 🔗 Connect Wallet
   └── MetaMask → Add Mantle Sepolia Network

2. 🚰 Get Test mETH
   └── Click "Get 10 Test mETH" (1 hour cooldown)

3. 💰 Deposit mETH
   └── Enter amount → Approve → Deposit

4. 🎯 Select Target Asset
   └── Choose: Real Estate / Bonds / Invoice Financing / Infrastructure

5. 🧪 Simulate Yield (Testnet)
   └── Click "Simulate 0.01 mETH Yield"

6. 🏆 Harvest & Buy RWA
   └── Click "Harvest & Buy RWA" → Receive fractions

7. 📊 View Portfolio
   └── Check "RWA Portfolio" tab for holdings
```

---

## 🧪 Testing

```bash
cd packages/foundry

# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Specific test file
forge test --match-path test/YieldVault.t.sol

# Gas report
forge test --gas-report
```

### Test Coverage

| Contract | Tests | Status |
|----------|-------|--------|
| YieldVault.sol | 13 | ✅ Pass |
| RealWorldAsset.sol | 22 | ✅ Pass |
| **Total** | **35** | **✅ All Pass** |

---

## 🔐 Security

### Implemented Measures

| Feature | Implementation |
|---------|----------------|
| Reentrancy Protection | OpenZeppelin `ReentrancyGuard` |
| Access Control | `Ownable2Step` + role-based modifiers |
| Pausability | Emergency pause on critical functions |
| Safe Transfers | `SafeERC20` for all token ops |
| Input Validation | Zero-checks on all parameters |

### Audit Status

⚠️ **Not Audited** - This is a hackathon project. Do not use in production without professional audit.

---

## 🗺️ Roadmap

### Phase 1: Hackathon MVP ✅
- [x] ERC-4626 Yield Vault
- [x] ERC-1155 RWA Tokens  
- [x] Mock yield generation
- [x] Dashboard UI
- [x] Portfolio View
- [x] RWA Marketplace
- [x] Mantle Sepolia deployment
- [x] 35/35 tests passing

### Phase 2: Post-Hackathon
- [ ] Real mETH yield integration
- [ ] Chainlink price feeds
- [ ] Auto-compound option
- [ ] Multi-asset DCA strategies

### Phase 3: Mainnet
- [ ] KYC/AML integration
- [ ] Real RWA partnerships
- [ ] Mantle DA document storage
- [ ] Governance token

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

---

<p align="center">
  <img src="packages/nextjs/public/logo.png" alt="Accrue" width="60"/>
</p>

<p align="center">
  <b>Accrue - Build Real Wealth From Your Yield</b>
</p>

<p align="center">
  Made with ❤️ for Mantle Global Hackathon 2025
</p>
