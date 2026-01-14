# 🏗️ Strata

## Yield-Collateralized RWA Purchasing Protocol

> **Mantle Global Hackathon 2025 - RWA/RealFi Track**

<div align="center">

```
██╗   ██╗██╗███████╗██╗     ██████╗ ██████╗ ██████╗ ██╗ ██████╗██╗  ██╗
╚██╗ ██╔╝██║██╔════╝██║     ██╔══██╗██╔══██╗██╔══██╗██║██╔════╝██║ ██╔╝
 ╚████╔╝ ██║█████╗  ██║     ██║  ██║██████╔╝██████╔╝██║██║     █████╔╝ 
  ╚██╔╝  ██║██╔══╝  ██║     ██║  ██║██╔══██╗██╔══██╗██║██║     ██╔═██╗ 
   ██║   ██║███████╗███████╗██████╔╝██████╔╝██║  ██║██║╚██████╗██║  ██╗
   ╚═╝   ╚═╝╚══════╝╚══════╝╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝
```

**Build Real Wealth From Your Yield**

[![Built on Mantle](https://img.shields.io/badge/Built%20on-Mantle-blue)](https://mantle.xyz)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-purple)](https://soliditylang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

---

## 🎯 The Problem

**DeFi yields are fleeting.** Users stake their assets, earn APY, but the yield just... sits there. It gets swapped, spent, or slowly erodes to inflation. Meanwhile, Real World Assets (real estate, bonds, treasuries) remain inaccessible to most crypto users.

## 💡 The Solution

**Strata** automatically converts your staking yield into fractionalized Real World Assets.

- **Stake mETH** on Mantle Network
- **Your principal stays 100% safe**
- **Yield automatically purchases** tokenized real estate, bonds, and more
- **Build a diversified RWA portfolio** passively

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Strata Protocol                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌────────────────┐                         ┌────────────────────────────┐ │
│   │                │                         │     REAL WORLD ASSETS      │ │
│   │   User Wallet  │                         │     (ERC-1155 Tokens)      │ │
│   │                │                         │                            │ │
│   │  ┌──────────┐  │    Principal            │  🏠 NYC Real Estate        │ │
│   │  │   mETH   │──┼──────────────┐          │  📜 Treasury Bonds         │ │
│   │  │ Holdings │  │              │          │  📑 Invoice Financing      │ │
│   │  └──────────┘  │              ▼          │  🌱 Infrastructure         │ │
│   │                │    ┌─────────────────┐  │                            │ │
│   │  ┌──────────┐  │    │                 │  └────────────────────────────┘ │
│   │  │   RWA    │◄─┼────│   YieldVault    │                │                │
│   │  │ Fractions│  │    │   (ERC-4626)    │────────────────┘                │
│   │  └──────────┘  │    │                 │    Yield → RWA Purchase         │
│   │                │    │  ┌───────────┐  │                                 │
│   └────────────────┘    │  │  Yield    │  │  ┌────────────────────────────┐ │
│                         │  │  Tracker  │  │  │      Mantle DA             │ │
│                         │  └───────────┘  │  │   (Legal Documents)        │ │
│                         └─────────────────┘  │   - Property Deeds         │ │
│                                              │   - Bond Certificates      │ │
│                                              │   - Compliance Proofs      │ │
│                                              └────────────────────────────┘ │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🌐 Mantle Ecosystem Alignment

Strata is **built specifically for Mantle Network**:

| Feature | Mantle Advantage |
|---------|------------------|
| **$mETH Collateral** | Native yield-bearing asset (~4% APY) |
| **Low Gas Fees** | Enables frequent micro-harvests ($0.001 vs $5+ on mainnet) |
| **Mantle DA** | Stores legal documents for RWA compliance |
| **High TPS** | Real-time yield tracking and updates |

---

## 📦 Project Structure

```
Strata/
├── packages/
│   ├── foundry/                    # Smart Contracts
│   │   ├── contracts/
│   │   │   ├── YieldVault.sol      # ERC-4626 vault with yield-to-RWA logic
│   │   │   ├── RealWorldAsset.sol  # ERC-1155 fractionalized RWAs
│   │   │   └── mocks/
│   │   │       └── MockMETH.sol    # Mock mETH for testnet
│   │   ├── script/
│   │   │   └── Deploy.s.sol        # Deployment scripts
│   │   ├── test/
│   │   │   └── YieldVault.t.sol    # Test suite
│   │   └── foundry.toml            # Foundry configuration
│   │
│   └── nextjs/                     # Frontend (Scaffold-ETH 2)
│       ├── app/                    # Next.js 14 App Router
│       ├── components/             # React components
│       └── hooks/                  # Wagmi hooks
│
└── README.md
```

---

## 🔧 Smart Contracts

### YieldVault.sol (ERC-4626)

The core protocol contract that:
- Accepts mETH deposits
- Tracks yield accrual in real-time
- Converts yield to RWA purchases via `harvestAndBuy()`
- Maintains 100% principal safety

**Key Functions:**

```solidity
// Deposit mETH into the vault
function deposit(uint256 assets, address receiver) returns (uint256 shares)

// Harvest yield and buy RWA fractions
function harvestAndBuy() returns (uint256 fractionsBought, uint256 yieldUsed)

// Set which RWA to accumulate
function setTargetAsset(uint256 assetId)

// View pending yield and progress
function getYieldProgress(address user) returns (
    uint256 currentYield,
    uint256 targetPrice,
    uint256 progressBps,
    uint256 fractionsEarned
)
```

### RealWorldAsset.sol (ERC-1155)

Fractionalized RWA tokens representing:

| ID | Asset | Price/Fraction | APY |
|----|-------|----------------|-----|
| 1 | NYC Real Estate | 0.01 ETH | 4.5% |
| 2 | Treasury Bonds | 0.001 ETH | 5.25% |
| 3 | Invoice Financing | 0.005 ETH | 8.5% |
| 4 | Infrastructure | 0.002 ETH | 6.5% |

---

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://getfoundry.sh/) installed
- Node.js 18+
- A wallet with testnet MNT ([Mantle Faucet](https://faucet.sepolia.mantle.xyz/))

### 1. Clone & Install

```bash
git clone https://github.com/your-username/Strata
cd Strata/packages/foundry

# Install dependencies
make install
```

### 2. Configure Environment

```bash
cp env-example.txt .env
# Edit .env with your private key
```

### 3. Build & Test

```bash
make build
make test
```

### 4. Deploy to Mantle Testnet

```bash
make deploy-testnet
```

---

## 📋 Deployment Guide

### Mantle Testnet Sepolia

**Network Details:**
- Chain ID: `5003`
- RPC: `https://rpc.sepolia.mantle.xyz`
- Explorer: `https://explorer.sepolia.mantle.xyz`
- Faucet: `https://faucet.sepolia.mantle.xyz`

**Deploy:**

```bash
forge script script/Deploy.s.sol:DeployStrata \
  --rpc-url https://rpc.sepolia.mantle.xyz \
  --broadcast \
  --verify \
  -vvvv
```

**Verify Contracts:**

```bash
forge verify-contract <CONTRACT_ADDRESS> RealWorldAsset \
  --chain-id 5003 \
  --verifier-url https://explorer.sepolia.mantle.xyz/api
```

---

## 🎮 Demo Flow

For hackathon demonstration:

```solidity
// 1. Get mock mETH from faucet
mockMETH.faucet(10 ether);

// 2. Approve vault
mockMETH.approve(yieldVault, 10 ether);

// 3. Deposit into vault
yieldVault.deposit(10 ether, userAddress);

// 4. Simulate yield (for demo speed)
yieldVault.mockYield(0.05 ether);

// 5. Harvest and buy RWA
yieldVault.harvestAndBuy();

// 6. Check RWA portfolio
rwaToken.getUserPortfolio(userAddress);
```

---

## 🔐 Security Considerations

| Risk | Mitigation |
|------|------------|
| Reentrancy | `ReentrancyGuard` on all state-changing functions |
| Access Control | Role-based permissions (MINTER_ROLE, ASSET_MANAGER_ROLE) |
| Principal Loss | User principal never leaves vault; only yield is used |
| Oracle Manipulation | Fixed fraction prices (future: Chainlink integration) |

---

## 🗺️ Roadmap

### Phase 1: Hackathon MVP ✅
- [x] ERC-4626 Yield Vault
- [x] ERC-1155 RWA Tokens
- [x] Mock yield generation
- [x] Basic dashboard UI

### Phase 2: Post-Hackathon
- [ ] Real mETH yield integration
- [ ] Chainlink price feeds for RWAs
- [ ] Auto-compound option
- [ ] Multi-asset DCA strategies

### Phase 3: Mainnet
- [ ] KYC/AML integration
- [ ] Real RWA partnerships
- [ ] Mantle DA document storage
- [ ] Governance token

---

## 👥 Team

Built with ❤️ for Mantle Global Hackathon 2025

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

---

<div align="center">

**🏗️ Strata - Build Real Wealth From Your Yield**

[Demo](https://Strata.xyz) · [Docs](https://docs.Strata.xyz) · [Twitter](https://twitter.com/Strata)

</div>
