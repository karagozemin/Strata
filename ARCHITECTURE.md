# Accrue Protocol Architecture

<p align="center">
  <img src="packages/nextjs/public/logo.png" alt="Accrue Logo" width="150"/>
</p>

<h3 align="center">Technical Architecture Document</h3>

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [High-Level Architecture](#2-high-level-architecture)
3. [Smart Contract Architecture](#3-smart-contract-architecture)
4. [Frontend Architecture](#4-frontend-architecture)
5. [Data Flow](#5-data-flow)
6. [State Management](#6-state-management)
7. [Security Architecture](#7-security-architecture)
8. [Deployment Architecture](#8-deployment-architecture)
9. [Integration Points](#9-integration-points)
10. [Technical Specifications](#10-technical-specifications)

---

## 1. System Overview

Accrue is a yield-to-RWA (Real World Asset) conversion protocol built on Mantle Network. The protocol enables users to automatically convert their mETH staking yield into fractionalized real-world assets such as real estate, bonds, and infrastructure investments.

### Core Principles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ACCRUE CORE PRINCIPLES                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. PRINCIPAL SAFETY     │  User deposits are never used for RWA purchases │
│                          │  Only yield is converted to real-world assets   │
│                                                                             │
│  2. PASSIVE ACCUMULATION │  No active management required from users       │
│                          │  Yield auto-converts on harvest                 │
│                                                                             │
│  3. FRACTIONAL OWNERSHIP │  Low barriers - anyone can own real assets      │
│                          │  Starting from 0.001 mETH per fraction          │
│                                                                             │
│  4. ON-CHAIN VERIFICATION│  All ownership verifiable on Mantle             │
│                          │  Legal documents stored via Mantle DA           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. High-Level Architecture

### System Components

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              ACCRUE ECOSYSTEM                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         PRESENTATION LAYER                          │    │
│  │                                                                     │    │
│  │  ┌───────────────┐  ┌───────────────┐  ┌────────────────────────┐  │    │
│  │  │   Dashboard   │  │  Portfolio    │  │     RWA Marketplace    │  │    │
│  │  │   Component   │  │   Viewer      │  │                        │  │    │
│  │  └───────────────┘  └───────────────┘  └────────────────────────┘  │    │
│  │                                                                     │    │
│  │  Next.js 14 │ React 18 │ TypeScript │ Tailwind CSS │ Framer Motion │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      │ Wagmi v2 + Viem                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         APPLICATION LAYER                           │    │
│  │                                                                     │    │
│  │  ┌───────────────────────┐  ┌───────────────────────────────────┐  │    │
│  │  │   Contract Hooks      │  │   State Management                │  │    │
│  │  │                       │  │                                   │  │    │
│  │  │  • useYieldVault      │  │  • React Query                    │  │    │
│  │  │  • useRealWorldAsset  │  │  • Wagmi Hooks                    │  │    │
│  │  │  • useScaffoldRead    │  │  • Local State                    │  │    │
│  │  │  • useScaffoldWrite   │  │                                   │  │    │
│  │  └───────────────────────┘  └───────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      │ JSON-RPC                              │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      BLOCKCHAIN LAYER (Mantle)                      │    │
│  │                                                                     │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │                    SMART CONTRACTS                          │   │    │
│  │  │                                                             │   │    │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │   │    │
│  │  │  │  MockMETH    │  │  YieldVault  │  │  RealWorldAsset  │  │   │    │
│  │  │  │  (ERC-20)    │  │  (ERC-4626)  │  │  (ERC-1155)      │  │   │    │
│  │  │  └──────────────┘  └──────────────┘  └──────────────────┘  │   │    │
│  │  │                                                             │   │    │
│  │  │  OpenZeppelin 5.x │ Solidity 0.8.24 │ Foundry              │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  │                                                                     │    │
│  │  Mantle Sepolia Testnet (Chain ID: 5003)                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Smart Contract Architecture

### Contract Hierarchy

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        SMART CONTRACT INHERITANCE                            │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  OpenZeppelin Contracts                                                      │
│  ├── ERC20                                                                   │
│  │   └── MockMETH.sol                                                        │
│  │       ├── _mint, _burn                                                    │
│  │       ├── faucet() - get test tokens                                      │
│  │       └── faucetCooldown - 1 hour limit                                   │
│  │                                                                           │
│  ├── ERC4626 + Ownable2Step + ReentrancyGuard + Pausable                    │
│  │   └── YieldVault.sol                                                      │
│  │       ├── deposit() - stake mETH                                          │
│  │       ├── withdraw() - unstake mETH                                       │
│  │       ├── setTargetAsset() - choose RWA type                              │
│  │       ├── harvestAndBuy() - convert yield to RWA                          │
│  │       ├── mockYield() - simulate yield (testnet)                          │
│  │       ├── getUserDashboard() - get user data                              │
│  │       └── getYieldProgress() - check yield status                         │
│  │                                                                           │
│  └── ERC1155 + Ownable2Step + ReentrancyGuard + Pausable                    │
│      └── RealWorldAsset.sol                                                  │
│          ├── mintFractions() - vault mints fractions                         │
│          ├── registerAsset() - add new asset types                           │
│          ├── getAssetInfo() - get asset details                              │
│          ├── getUserPortfolio() - get user holdings                          │
│          └── calculateFractions() - price calculation                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Contract Interactions

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        CONTRACT INTERACTION FLOW                             │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  User                 MockMETH              YieldVault          RWA Token    │
│   │                      │                      │                    │       │
│   │──── faucet() ───────▶│                      │                    │       │
│   │◀─── 10 mETH ─────────│                      │                    │       │
│   │                      │                      │                    │       │
│   │──── approve() ──────▶│                      │                    │       │
│   │                      │                      │                    │       │
│   │──── deposit() ──────────────────────────────▶│                    │       │
│   │                      │◀─ transferFrom() ────│                    │       │
│   │◀─── shares ──────────────────────────────────│                    │       │
│   │                      │                      │                    │       │
│   │──── setTargetAsset(1) ─────────────────────▶│                    │       │
│   │                      │                      │                    │       │
│   │                      │      [TIME PASSES - YIELD ACCRUES]        │       │
│   │                      │                      │                    │       │
│   │──── harvestAndBuy() ───────────────────────▶│                    │       │
│   │                      │                      │─── mintFractions() ─▶│       │
│   │◀─── RWA fractions ───────────────────────────────────────────────│       │
│   │                      │                      │                    │       │
│   │──── withdraw() ────────────────────────────▶│                    │       │
│   │◀─── mETH returned ───│◀─── transfer() ─────│                    │       │
│                          │                      │                    │       │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Storage Layout

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           YIELDVAULT STORAGE                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  State Variables:                                                            │
│  ├── rwaToken: IRealWorldAsset         // Reference to RWA contract         │
│  ├── totalDeposited: uint256           // Total mETH in vault               │
│  ├── totalYieldGenerated: uint256      // Cumulative yield                  │
│  ├── minHarvestThreshold: uint256      // Min yield to harvest (0.001 mETH) │
│  │                                                                          │
│  Mappings:                                                                   │
│  ├── userDeposit[address] => uint256   // User's principal amount           │
│  ├── userPendingYield[address] => uint256 // Unharvested yield              │
│  ├── userTotalHarvested[address] => uint256 // Lifetime harvested           │
│  ├── userTargetAsset[address] => uint256 // Selected RWA type (1-4)         │
│  └── userLastDeposit[address] => uint256 // Timestamp for yield calc        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                         REALWORLDASSET STORAGE                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  State Variables:                                                            │
│  ├── vault: address                    // Authorized minting address        │
│  ├── assetCount: uint256               // Number of registered assets       │
│  │                                                                          │
│  Mappings:                                                                   │
│  ├── assets[uint256] => AssetInfo      // Asset details by ID               │
│  │   ├── name: string                  // "NYC Real Estate"                 │
│  │   ├── symbol: string                // "NYC-RE"                          │
│  │   ├── pricePerFraction: uint256     // 0.01 ether                        │
│  │   ├── totalSupply: uint256          // Minted fractions                  │
│  │   ├── maxSupply: uint256            // Supply cap                        │
│  │   ├── apyBps: uint256               // 450 = 4.5%                        │
│  │   ├── legalDocHash: bytes32         // Mantle DA document hash           │
│  │   └── isActive: bool                // Accepting purchases               │
│  │                                                                          │
│  └── registeredAssets: uint256[]       // List of all asset IDs             │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Frontend Architecture

### Component Structure

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          FRONTEND COMPONENTS                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  packages/nextjs/                                                            │
│  │                                                                          │
│  ├── app/                              # Next.js 14 App Router              │
│  │   ├── layout.tsx                    # Root layout + providers            │
│  │   ├── page.tsx                      # Main page (Dashboard + Nav)        │
│  │   └── globals.css                   # Global styles                      │
│  │                                                                          │
│  ├── components/                       # React Components                   │
│  │   ├── Hero.tsx                      # Landing hero section               │
│  │   ├── Dashboard.tsx                 # Main user dashboard                │
│  │   ├── PortfolioView.tsx            # RWA portfolio display              │
│  │   ├── RWAMarketplace.tsx           # Asset selection UI                 │
│  │   ├── Header.tsx                    # Navigation header                  │
│  │   ├── Footer.tsx                    # Page footer                        │
│  │   └── scaffold-eth/                 # Scaffold-ETH 2 components          │
│  │       ├── Balance.tsx               # Wallet balance display             │
│  │       ├── Address.tsx               # Address formatting                 │
│  │       └── RainbowKitProvider.tsx   # Wallet connection                  │
│  │                                                                          │
│  ├── hooks/                            # Custom React Hooks                 │
│  │   ├── useYieldVault.ts             # YieldVault interactions            │
│  │   ├── useRealWorldAsset.ts         # RWA token interactions             │
│  │   ├── scaffold-eth/                 # Scaffold-ETH 2 hooks               │
│  │   │   ├── useScaffoldReadContract  # Read contract state                │
│  │   │   └── useScaffoldWriteContract # Write transactions                 │
│  │   └── useTransactor.ts             # Transaction wrapper                │
│  │                                                                          │
│  ├── contracts/                        # Contract ABIs + Addresses          │
│  │   ├── deployedContracts.ts         # Contract deployment info           │
│  │   └── externalContracts.ts         # External contract info             │
│  │                                                                          │
│  └── public/                           # Static assets                      │
│      ├── logo.png                      # Accrue logo                        │
│      ├── favicon.png                   # Browser favicon                    │
│      └── icon.png                      # App icon                           │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Component Relationships

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        COMPONENT HIERARCHY                                   │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  RootLayout (layout.tsx)                                                     │
│  └── ScaffoldEthAppWithProviders                                            │
│      ├── RainbowKitProvider          // Wallet connection                   │
│      ├── WagmiProvider               // Ethereum hooks                      │
│      └── HomePage (page.tsx)                                                │
│          │                                                                  │
│          ├── Navbar                                                         │
│          │   ├── Logo                // Accrue branding                     │
│          │   ├── TabSelector         // Dashboard/Portfolio/Marketplace    │
│          │   ├── BalanceDisplay      // MNT + mETH balances                │
│          │   └── RainbowKitButton    // Connect wallet                     │
│          │                                                                  │
│          └── TabContent (conditional)                                       │
│              │                                                              │
│              ├── [Hero]              // When not connected                  │
│              │   └── ConnectButton                                          │
│              │                                                              │
│              ├── [Dashboard]         // Main dashboard tab                  │
│              │   ├── UserStats       // Deposited, yield, shares           │
│              │   ├── DepositForm     // Amount input + buttons             │
│              │   ├── YieldProgress   // Progress bar + actions             │
│              │   └── TargetAsset     // Current target display             │
│              │                                                              │
│              ├── [PortfolioView]     // Portfolio tab                       │
│              │   ├── TotalValue      // Portfolio summary                  │
│              │   └── AssetCards      // Individual RWA holdings            │
│              │                                                              │
│              └── [RWAMarketplace]    // Marketplace tab                     │
│                  └── AssetCards      // Available assets + Set Target      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Data Flow

### Read Data Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          READ DATA FLOW                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Component                 Hook                     Contract                 │
│      │                      │                          │                     │
│      │                      │                          │                     │
│  Dashboard ─────▶ useYieldVault() ────────▶ YieldVault.getUserDashboard()   │
│      │                      │                          │                     │
│      │           Returns:   │                          │                     │
│      │           ├── principal                         │                     │
│      │           ├── shares                            │                     │
│      │           ├── pendingYield                      │                     │
│      │           ├── totalHarvested                    │                     │
│      │           ├── targetAssetId                     │                     │
│      │           └── rwaValue                          │                     │
│      │                      │                          │                     │
│      │                      │                          │                     │
│  PortfolioView ──▶ useRealWorldAsset() ──▶ RealWorldAsset.getUserPortfolio()│
│      │                      │                          │                     │
│      │           Returns:   │                          │                     │
│      │           ├── assetIds[]                        │                     │
│      │           ├── balances[]                        │                     │
│      │           └── totalValue                        │                     │
│      │                      │                          │                     │
│      │                      │                          │                     │
│  Marketplace ────▶ useRealWorldAsset() ──▶ RealWorldAsset.getAllAssetIds()  │
│                             │              RealWorldAsset.getAssetInfo()    │
│                             │                          │                     │
│                  Returns per asset:                    │                     │
│                  ├── name                              │                     │
│                  ├── symbol                            │                     │
│                  ├── pricePerFraction                  │                     │
│                  ├── totalSupply                       │                     │
│                  ├── apyBps                            │                     │
│                  └── isActive                          │                     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Write Data Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          WRITE DATA FLOW                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  User Action         UI Component        Hook/Contract        Blockchain     │
│      │                    │                    │                    │        │
│      │                    │                    │                    │        │
│  Click "Deposit"         │                    │                    │        │
│      │────────────────────▶ DepositForm       │                    │        │
│      │                    │                    │                    │        │
│      │                    │──── approve() ────▶ MockMETH           │        │
│      │                    │                    │──── tx ───────────▶│        │
│      │                    │◀─── confirm ───────│◀───────────────────│        │
│      │                    │                    │                    │        │
│      │                    │──── deposit() ────▶ YieldVault         │        │
│      │                    │                    │──── tx ───────────▶│        │
│      │                    │◀─── confirm ───────│◀───────────────────│        │
│      │                    │                    │                    │        │
│      │◀─── toast.success("Deposited!") ────────│                    │        │
│      │                    │                    │                    │        │
│      │                    │                    │                    │        │
│  Click "Harvest"         │                    │                    │        │
│      │────────────────────▶ Dashboard          │                    │        │
│      │                    │                    │                    │        │
│      │                    │── harvestAndBuy() ▶ YieldVault         │        │
│      │                    │                    │                    │        │
│      │                    │                    │── mintFractions() ▶        │
│      │                    │                    │     RealWorldAsset│        │
│      │                    │                    │          │        │        │
│      │                    │                    │◀─────────│────────│        │
│      │                    │◀─── confirm ───────│                    │        │
│      │                    │                    │                    │        │
│      │◀─── toast.success("Harvested X fractions!") ────────────────│        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. State Management

### State Sources

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          STATE MANAGEMENT                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     ON-CHAIN STATE (Source of Truth)                │    │
│  │                                                                     │    │
│  │  YieldVault                      RealWorldAsset                     │    │
│  │  ├── userDeposit[addr]           ├── balanceOf(addr, id)           │    │
│  │  ├── userPendingYield[addr]      ├── assets[id].totalSupply        │    │
│  │  ├── userTotalHarvested[addr]    └── assets[id].pricePerFraction   │    │
│  │  └── userTargetAsset[addr]                                         │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      │ Wagmi useReadContract                 │
│                                      │ (auto-refresh on block)               │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     REACT QUERY CACHE                               │    │
│  │                                                                     │    │
│  │  Automatic caching and invalidation via Wagmi/TanStack Query       │    │
│  │  ├── Stale time: 30 seconds                                        │    │
│  │  ├── Cache time: 5 minutes                                         │    │
│  │  └── Auto-refetch: On window focus, network reconnect              │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     LOCAL COMPONENT STATE                           │    │
│  │                                                                     │    │
│  │  useState for:                                                      │    │
│  │  ├── activeTab: "dashboard" | "portfolio" | "marketplace"          │    │
│  │  ├── depositAmount: string (input field)                           │    │
│  │  ├── isLoading: boolean (transaction pending)                      │    │
│  │  └── faucetCooldown: number (countdown timer)                      │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Security Architecture

### Access Control Model

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          ACCESS CONTROL                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        YieldVault Roles                              │   │
│  ├──────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  OWNER (Ownable2Step)                                                │   │
│  │  ├── pause() / unpause()                                             │   │
│  │  ├── setMinHarvestThreshold()                                        │   │
│  │  ├── setRWAToken()                                                   │   │
│  │  └── emergencyWithdraw()                                             │   │
│  │                                                                      │   │
│  │  ANY USER                                                            │   │
│  │  ├── deposit()                                                       │   │
│  │  ├── withdraw() (own funds only)                                     │   │
│  │  ├── setTargetAsset()                                                │   │
│  │  ├── harvestAndBuy()                                                 │   │
│  │  └── mockYield() (testnet only)                                      │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                      RealWorldAsset Roles                            │   │
│  ├──────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  OWNER (Ownable2Step)                                                │   │
│  │  ├── pause() / unpause()                                             │   │
│  │  ├── setVault()                                                      │   │
│  │  ├── registerAsset()                                                 │   │
│  │  └── updateAsset()                                                   │   │
│  │                                                                      │   │
│  │  VAULT ONLY                                                          │   │
│  │  └── mintFractions() (only callable by YieldVault)                   │   │
│  │                                                                      │   │
│  │  ANY USER                                                            │   │
│  │  ├── transfer() (ERC1155 standard)                                   │   │
│  │  └── view functions                                                  │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Security Measures

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        SECURITY MEASURES                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  SMART CONTRACT SECURITY                                                     │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                                                                    │     │
│  │  1. REENTRANCY PROTECTION                                          │     │
│  │     └── OpenZeppelin ReentrancyGuard on all external functions     │     │
│  │                                                                    │     │
│  │  2. ACCESS CONTROL                                                 │     │
│  │     ├── Ownable2Step: 2-step ownership transfer                    │     │
│  │     └── onlyVault modifier for minting                             │     │
│  │                                                                    │     │
│  │  3. PAUSABILITY                                                    │     │
│  │     └── Emergency pause functionality on critical functions        │     │
│  │                                                                    │     │
│  │  4. INPUT VALIDATION                                               │     │
│  │     ├── Zero address checks                                        │     │
│  │     ├── Amount validation (> 0)                                    │     │
│  │     └── Asset existence checks                                     │     │
│  │                                                                    │     │
│  │  5. SAFE TRANSFERS                                                 │     │
│  │     └── OpenZeppelin SafeERC20 for token operations                │     │
│  │                                                                    │     │
│  │  6. OVERFLOW PROTECTION                                            │     │
│  │     └── Solidity 0.8+ built-in overflow checks                     │     │
│  │                                                                    │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│  FRONTEND SECURITY                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                                                                    │     │
│  │  1. WALLET CONNECTION                                              │     │
│  │     └── RainbowKit secure wallet adapter                           │     │
│  │                                                                    │     │
│  │  2. TRANSACTION CONFIRMATION                                       │     │
│  │     └── Clear UI before signing any transaction                    │     │
│  │                                                                    │     │
│  │  3. INPUT SANITIZATION                                             │     │
│  │     └── Number validation before contract calls                    │     │
│  │                                                                    │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Deployment Architecture

### Contract Deployment

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                      DEPLOYMENT SEQUENCE                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Step 1: Deploy MockMETH                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  MockMETH meth = new MockMETH("Mock mETH", "mETH");                 │    │
│  │  Address: 0xB7Ab966115aF7d21E7Aa6e31A9AdfC92291092E0               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  Step 2: Deploy RealWorldAsset                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  RealWorldAsset rwa = new RealWorldAsset(                          │    │
│  │      "ipfs://base-uri"                                             │    │
│  │  );                                                                │    │
│  │  Address: 0xa520c7Aa947f3B610d274377D261Eb5AcD70883F               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  Step 3: Deploy YieldVault                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  YieldVault vault = new YieldVault(                                │    │
│  │      IERC20(meth),                                                 │    │
│  │      IRealWorldAsset(rwa)                                          │    │
│  │  );                                                                │    │
│  │  Address: 0x9C70C2F67028e5464F5b60E29648240e358E83B6               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  Step 4: Configure RealWorldAsset                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  rwa.setVault(address(vault));                                     │    │
│  │  // Register default asset types (1-4)                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Network Configuration

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                      NETWORK CONFIGURATION                                   │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  MANTLE SEPOLIA TESTNET                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │  Chain ID:        5003                                              │    │
│  │  RPC URL:         https://rpc.sepolia.mantle.xyz                    │    │
│  │  Explorer:        https://sepolia.mantlescan.xyz                    │    │
│  │  Faucet:          https://faucet.sepolia.mantle.xyz                 │    │
│  │  Native Token:    MNT (Mantle)                                      │    │
│  │  Block Time:      ~2 seconds                                        │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  MANTLE MAINNET (Future)                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │  Chain ID:        5000                                              │    │
│  │  RPC URL:         https://rpc.mantle.xyz                            │    │
│  │  Explorer:        https://mantlescan.xyz                            │    │
│  │  Native Token:    MNT                                               │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Integration Points

### External Dependencies

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                      EXTERNAL INTEGRATIONS                                   │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CURRENT (MVP)                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │  • Mantle Sepolia RPC                                               │    │
│  │  • RainbowKit (wallet connection)                                   │    │
│  │  • WalletConnect (mobile wallets)                                   │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  FUTURE INTEGRATIONS                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                     │    │
│  │  🔮 Chainlink Price Feeds                                           │    │
│  │     └── Real-time RWA valuations                                    │    │
│  │                                                                     │    │
│  │  🔮 mETH Protocol (Mainnet)                                         │    │
│  │     └── Real yield from Mantle staking                              │    │
│  │                                                                     │    │
│  │  🔮 Mantle DA                                                       │    │
│  │     └── Legal document storage                                      │    │
│  │                                                                     │    │
│  │  🔮 KYC/AML Provider                                                │    │
│  │     └── Regulatory compliance                                       │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 10. Technical Specifications

### Smart Contract Specifications

| Parameter | Value |
|-----------|-------|
| Solidity Version | 0.8.24 |
| OpenZeppelin Version | 5.5.0 |
| EVM Version | Shanghai |
| Optimizer | Enabled (200 runs) |
| License | MIT |

### Gas Estimates

| Function | Estimated Gas |
|----------|---------------|
| deposit() | ~150,000 |
| withdraw() | ~120,000 |
| setTargetAsset() | ~50,000 |
| harvestAndBuy() | ~200,000 |
| faucet() | ~80,000 |

### Frontend Specifications

| Technology | Version |
|------------|---------|
| Next.js | 14.x |
| React | 18.x |
| TypeScript | 5.x |
| Wagmi | 2.x |
| Viem | 2.x |
| RainbowKit | 2.x |
| Tailwind CSS | 3.x |
| Framer Motion | 11.x |

---

<p align="center">
  <b>Accrue - Build Real Wealth From Your Yield</b>
</p>

<p align="center">
  <img src="packages/nextjs/public/logo.png" alt="Accrue" width="80"/>
</p>
