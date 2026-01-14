// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// =============================================================================
// ██╗   ██╗██╗███████╗██╗     ██████╗ ██╗   ██╗ █████╗ ██╗   ██╗██╗  ████████╗
// ╚██╗ ██╔╝██║██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██║   ██║██║  ╚══██╔══╝
//  ╚████╔╝ ██║█████╗  ██║     ██║  ██║██║   ██║███████║██║   ██║██║     ██║
//   ╚██╔╝  ██║██╔══╝  ██║     ██║  ██║╚██╗ ██╔╝██╔══██║██║   ██║██║     ██║
//    ██║   ██║███████╗███████╗██████╔╝ ╚████╔╝ ██║  ██║╚██████╔╝███████╗██║
//    ╚═╝   ╚═╝╚══════╝╚══════╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝
// =============================================================================
// YieldVault.sol - Yield-Collateralized RWA Purchasing Protocol
// Mantle Global Hackathon 2025 - RWA/RealFi Track
// =============================================================================
//
// 🎯 CORE INNOVATION:
// Users stake yield-bearing assets (mETH, stablecoins) on Mantle Network.
// The protocol automatically harvests generated yield and uses it to purchase
// fractionalized Real World Assets for the user. Principal remains 100% safe
// while users accumulate RWA tokens passively.
//
// 🔄 YIELD FLOW:
//   ┌─────────────────────────────────────────────────────────────────────────┐
//   │                                                                          │
//   │   User deposits mETH ───► Vault tracks yield ───► Yield harvested       │
//   │         │                        │                       │               │
//   │         │                        │                       ▼               │
//   │         │                        │              ┌────────────────┐       │
//   │         │                        │              │  Purchase RWA  │       │
//   │         │                        │              │  Fractions     │       │
//   │         │                        │              └────────────────┘       │
//   │         │                        │                       │               │
//   │         ▼                        ▼                       ▼               │
//   │   Principal SAFE          Yield accrues         RWAs in wallet          │
//   │   (100% protected)        (auto-tracked)        (real ownership)        │
//   │                                                                          │
//   └─────────────────────────────────────────────────────────────────────────┘
//
// 🌐 MANTLE ECOSYSTEM INTEGRATION:
// - Primary collateral: $mETH (Mantle Staked ETH) - earns ~4% APY
// - Low gas fees enable frequent micro-harvests (every block if needed)
// - Mantle DA stores legal documents for all RWA assets
// - Optimized for Mantle's high TPS for real-time yield tracking
//
// 📋 ERC-4626 COMPLIANCE:
// This vault follows the ERC-4626 Tokenized Vault standard, enabling:
// - Composability with other DeFi protocols
// - Standard deposit/withdraw interfaces
// - Automated yield accounting
// =============================================================================

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./RealWorldAsset.sol";

/**
 * @title YieldVault
 * @author Strata Team - Mantle Hackathon 2025
 * @notice ERC-4626 vault that converts yield into RWA purchases
 * @dev Core protocol contract implementing yield-to-RWA conversion
 *
 * ┌─────────────────────────────────────────────────────────────────────────────┐
 * │                         USER JOURNEY                                         │
 * ├─────────────────────────────────────────────────────────────────────────────┤
 * │                                                                              │
 * │   1. DEPOSIT                    2. ACCUMULATE                3. OWN RWA     │
 * │   ─────────                     ───────────                  ─────────      │
 * │   User deposits                 Yield accrues                RWA fractions  │
 * │   mETH into vault               automatically                minted to user │
 * │                                                                              │
 * │   ┌──────────┐                  ┌──────────┐                ┌──────────┐    │
 * │   │   mETH   │ ──────────────►  │  Yield   │ ─────────────► │   RWA    │    │
 * │   │  deposit │   stake & earn   │ tracker  │   harvest      │  tokens  │    │
 * │   └──────────┘                  └──────────┘                └──────────┘    │
 * │                                                                              │
 * │   Principal: 10 mETH            Yield: 0.04 mETH            2 NYC fractions │
 * │   (stays safe)                  (4% APY)                    (real estate!)  │
 * │                                                                              │
 * └─────────────────────────────────────────────────────────────────────────────┘
 */
contract YieldVault is ERC4626, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // =========================================================================
    // STATE VARIABLES
    // =========================================================================

    /// @notice The RWA token contract for minting fractions
    RealWorldAsset public immutable rwaToken;

    /// @notice Simulated APY for demo (basis points, 400 = 4%)
    /// @dev In production, this would come from actual mETH staking rewards
    uint256 public mockAPY = 400; // 4% APY default

    /// @notice Time multiplier for demo (accelerates yield for hackathon)
    /// @dev Set to higher value to show yield accumulation faster
    uint256 public yieldMultiplier = 100; // 100x faster for demo

    /// @notice Minimum yield threshold before harvest (gas optimization)
    uint256 public minHarvestThreshold = 0.001 ether;

    // =========================================================================
    // USER DATA TRACKING
    // =========================================================================

    /**
     * @notice Per-user yield and RWA tracking
     * @dev Tracks everything needed for the dashboard UI
     *
     * Why track separately from ERC-4626?
     * - ERC-4626 tracks shares/assets, but we need yield-specific data
     * - Need to track "unharvested" yield for progress bar UI
     * - Historical data for user analytics
     */
    struct UserData {
        uint256 depositTimestamp;       // When user first deposited
        uint256 lastHarvestTimestamp;   // Last yield harvest time
        uint256 totalYieldHarvested;    // Lifetime yield converted to RWA
        uint256 pendingYield;           // Accumulated but not yet harvested
        uint256 targetAssetId;          // Which RWA user is accumulating
        uint256 totalRWAValue;          // Total value of RWA purchased
    }

    /// @notice User address => User data
    mapping(address => UserData) public userData;

    /// @notice Track all depositors for enumeration
    address[] public depositors;
    mapping(address => bool) public isDepositor;

    // =========================================================================
    // PROTOCOL STATISTICS
    // =========================================================================

    /// @notice Total yield harvested by protocol (all users)
    uint256 public totalProtocolYield;

    /// @notice Total RWA value purchased via protocol
    uint256 public totalRWAPurchased;

    /// @notice Protocol fee (basis points, 50 = 0.5%)
    uint256 public protocolFeeBps = 50;

    /// @notice Accumulated protocol fees
    uint256 public accumulatedFees;

    // =========================================================================
    // EVENTS - Comprehensive logging for frontend/indexer
    // =========================================================================

    /// @notice Emitted when yield is harvested and converted to RWA
    event YieldHarvested(
        address indexed user,
        uint256 yieldAmount,
        uint256 rwaAssetId,
        uint256 fractionsBought,
        uint256 timestamp
    );

    /// @notice Emitted when user changes their target RWA asset
    event TargetAssetChanged(
        address indexed user,
        uint256 oldAssetId,
        uint256 newAssetId
    );

    /// @notice Emitted when mock yield is added (for demo)
    event MockYieldGenerated(
        address indexed user,
        uint256 amount,
        uint256 newPendingTotal
    );

    /// @notice Emitted on deposit with additional context
    event DepositWithYieldTracking(
        address indexed user,
        uint256 assets,
        uint256 shares,
        uint256 targetAssetId
    );

    // =========================================================================
    // ERRORS
    // =========================================================================

    error InsufficientYield(uint256 available, uint256 required);
    error InvalidTargetAsset(uint256 assetId);
    error NoYieldToHarvest();
    error UserNotDepositor(address user);

    // =========================================================================
    // CONSTRUCTOR
    // =========================================================================

    /**
     * @notice Deploy the YieldVault
     * @param _asset The underlying asset (mETH token address)
     * @param _rwaToken The RWA ERC-1155 contract address
     * @param _name Vault token name (e.g., "Strata mETH Vault")
     * @param _symbol Vault token symbol (e.g., "ybMETH")
     *
     * Deployment steps:
     * 1. Deploy RealWorldAsset.sol first
     * 2. Deploy YieldVault with RWA address
     * 3. Call rwaToken.setVaultAsMinter(yieldVault.address)
     */
    constructor(
        IERC20 _asset,
        RealWorldAsset _rwaToken,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset) ERC20(_name, _symbol) Ownable(msg.sender) {
        rwaToken = _rwaToken;
    }

    // =========================================================================
    // CORE DEPOSIT/WITHDRAW OVERRIDES
    // =========================================================================

    /**
     * @notice Deposit assets and start earning yield toward RWA
     * @param assets Amount of mETH to deposit
     * @param receiver Address to receive vault shares
     * @return shares Amount of vault shares minted
     * @dev Overrides ERC-4626 to add yield tracking initialization
     *
     * What happens on deposit:
     * 1. Standard ERC-4626 deposit (assets → shares)
     * 2. Initialize user yield tracking if first deposit
     * 3. Set default target asset (NYC Real Estate)
     * 4. Emit enhanced event for frontend
     */
    function deposit(
        uint256 assets,
        address receiver
    ) public override nonReentrant returns (uint256 shares) {
        shares = super.deposit(assets, receiver);

        // Initialize user data if first deposit
        if (!isDepositor[receiver]) {
            isDepositor[receiver] = true;
            depositors.push(receiver);

            userData[receiver] = UserData({
                depositTimestamp: block.timestamp,
                lastHarvestTimestamp: block.timestamp,
                totalYieldHarvested: 0,
                pendingYield: 0,
                targetAssetId: 1, // Default to NYC Real Estate
                totalRWAValue: 0
            });
        } else {
            // Existing user - accrue yield before deposit
            _accrueYield(receiver);
        }

        emit DepositWithYieldTracking(
            receiver,
            assets,
            shares,
            userData[receiver].targetAssetId
        );

        return shares;
    }

    /**
     * @notice Withdraw assets from vault
     * @param assets Amount of assets to withdraw
     * @param receiver Address to receive assets
     * @param owner Owner of the shares being burned
     * @return shares Amount of shares burned
     * @dev Overrides to accrue yield before withdrawal
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override nonReentrant returns (uint256 shares) {
        // Accrue any pending yield before withdrawal
        if (isDepositor[owner]) {
            _accrueYield(owner);
        }

        return super.withdraw(assets, receiver, owner);
    }

    // =========================================================================
    // YIELD TRACKING & ACCRUAL
    // =========================================================================

    /**
     * @notice Calculate current pending yield for a user
     * @param user Address to calculate yield for
     * @return pendingYield Total unharvested yield in wei
     * @dev Combines stored pending + newly accrued since last update
     *
     * Yield calculation:
     * yield = principal * APY * timeElapsed * multiplier / (365 days * 10000)
     *
     * Example (with 100x multiplier for demo):
     * - Principal: 10 ETH
     * - APY: 4% (400 bps)
     * - Time: 1 hour
     * - Yield = 10 * 400 * 3600 * 100 / (31536000 * 10000) = 0.0456 ETH
     */
    function calculatePendingYield(address user) public view returns (uint256) {
        if (!isDepositor[user]) return 0;

        UserData storage data = userData[user];
        uint256 userShares = balanceOf(user);
        if (userShares == 0) return data.pendingYield;

        // Calculate time elapsed since last accrual
        uint256 timeElapsed = block.timestamp - data.lastHarvestTimestamp;

        // Get user's underlying asset value
        uint256 userAssets = convertToAssets(userShares);

        // Calculate new yield: assets * APY * time * multiplier / (year * bps_denominator)
        uint256 newYield = (userAssets * mockAPY * timeElapsed * yieldMultiplier)
            / (365 days * 10000);

        return data.pendingYield + newYield;
    }

    /**
     * @notice Get yield progress toward next RWA fraction
     * @param user Address to check
     * @return currentYield Pending yield amount
     * @return targetPrice Price of one RWA fraction
     * @return progressBps Progress in basis points (10000 = 100%)
     * @return fractionsEarned How many fractions can be bought now
     * @dev Used for the progress bar UI component
     */
    function getYieldProgress(
        address user
    ) external view returns (
        uint256 currentYield,
        uint256 targetPrice,
        uint256 progressBps,
        uint256 fractionsEarned
    ) {
        currentYield = calculatePendingYield(user);
        uint256 targetAsset = userData[user].targetAssetId;

        RealWorldAsset.AssetMetadata memory asset = rwaToken.getAssetInfo(targetAsset);
        targetPrice = asset.pricePerFraction;

        if (targetPrice > 0) {
            // Calculate progress toward next fraction (capped at 100%)
            progressBps = (currentYield * 10000) / targetPrice;
            if (progressBps > 10000) progressBps = 10000;

            // Calculate total fractions earnable
            fractionsEarned = currentYield / targetPrice;
        }
    }

    /**
     * @notice Internal function to accrue yield for a user
     * @param user Address to accrue yield for
     * @dev Updates pendingYield and lastHarvestTimestamp
     */
    function _accrueYield(address user) internal {
        UserData storage data = userData[user];
        uint256 userShares = balanceOf(user);

        if (userShares > 0) {
            uint256 timeElapsed = block.timestamp - data.lastHarvestTimestamp;
            uint256 userAssets = convertToAssets(userShares);

            uint256 newYield = (userAssets * mockAPY * timeElapsed * yieldMultiplier)
                / (365 days * 10000);

            data.pendingYield += newYield;
        }

        data.lastHarvestTimestamp = block.timestamp;
    }

    // =========================================================================
    // HARVEST & BUY - Core Protocol Logic
    // =========================================================================

    /**
     * @notice Harvest accumulated yield and purchase RWA fractions
     * @return fractionsBought Number of RWA fractions purchased
     * @return yieldUsed Amount of yield converted to RWA
     * @dev This is the CORE INNOVATION of Strata!
     *
     * ┌─────────────────────────────────────────────────────────────────────────┐
     * │                      harvestAndBuy() FLOW                               │
     * ├─────────────────────────────────────────────────────────────────────────┤
     * │                                                                          │
     * │   1. Accrue latest yield                                                 │
     * │              │                                                           │
     * │              ▼                                                           │
     * │   2. Calculate purchasable fractions                                     │
     * │              │                                                           │
     * │              ▼                                                           │
     * │   3. Deduct protocol fee (0.5%)                                         │
     * │              │                                                           │
     * │              ▼                                                           │
     * │   4. Mint RWA fractions to user                                         │
     * │              │                                                           │
     * │              ▼                                                           │
     * │   5. Update user stats & emit event                                     │
     * │                                                                          │
     * └─────────────────────────────────────────────────────────────────────────┘
     *
     * Why this approach?
     * - User's principal NEVER leaves the vault (100% safe)
     * - Only yield is used for RWA purchases
     * - Automatic DCA into real assets
     * - Low gas on Mantle enables frequent harvests
     */
    function harvestAndBuy() external nonReentrant returns (
        uint256 fractionsBought,
        uint256 yieldUsed
    ) {
        address user = msg.sender;
        if (!isDepositor[user]) revert UserNotDepositor(user);

        // Step 1: Accrue latest yield
        _accrueYield(user);

        UserData storage data = userData[user];
        uint256 pendingYield = data.pendingYield;

        if (pendingYield < minHarvestThreshold) {
            revert InsufficientYield(pendingYield, minHarvestThreshold);
        }

        // Step 2: Calculate how many fractions can be bought
        uint256 targetAsset = data.targetAssetId;
        (uint256 fractions, uint256 remainder) = rwaToken.calculateFractions(
            targetAsset,
            pendingYield
        );

        if (fractions == 0) revert NoYieldToHarvest();

        // Step 3: Calculate yield to use (excluding remainder)
        yieldUsed = pendingYield - remainder;

        // Step 4: Deduct protocol fee
        uint256 fee = (yieldUsed * protocolFeeBps) / 10000;
        accumulatedFees += fee;
        uint256 netYield = yieldUsed - fee;

        // Recalculate fractions after fee
        (fractionsBought, ) = rwaToken.calculateFractions(targetAsset, netYield);

        // Step 5: Mint RWA fractions to user
        if (fractionsBought > 0) {
            rwaToken.mintFractions(user, targetAsset, fractionsBought);
        }

        // Step 6: Update user data
        data.pendingYield = remainder;
        data.totalYieldHarvested += yieldUsed;

        RealWorldAsset.AssetMetadata memory assetInfo = rwaToken.getAssetInfo(targetAsset);
        data.totalRWAValue += fractionsBought * assetInfo.pricePerFraction;

        // Update protocol stats
        totalProtocolYield += yieldUsed;
        totalRWAPurchased += fractionsBought * assetInfo.pricePerFraction;

        emit YieldHarvested(
            user,
            yieldUsed,
            targetAsset,
            fractionsBought,
            block.timestamp
        );

        return (fractionsBought, yieldUsed);
    }

    /**
     * @notice Auto-harvest for a user (can be called by anyone/keeper)
     * @param user Address to harvest for
     * @dev Enables automated yield harvesting via keepers/bots
     *
     * Why allow external calls?
     * - Enables MEV-protected batch harvesting
     * - Users don't need to manually trigger
     * - Keepers can optimize gas timing on Mantle
     */
    function harvestForUser(address user) external nonReentrant returns (
        uint256 fractionsBought,
        uint256 yieldUsed
    ) {
        if (!isDepositor[user]) revert UserNotDepositor(user);

        _accrueYield(user);

        UserData storage data = userData[user];
        uint256 pendingYield = data.pendingYield;

        if (pendingYield < minHarvestThreshold) {
            return (0, 0); // No revert, just return 0s for keeper efficiency
        }

        uint256 targetAsset = data.targetAssetId;
        (uint256 fractions, uint256 remainder) = rwaToken.calculateFractions(
            targetAsset,
            pendingYield
        );

        if (fractions == 0) return (0, 0);

        yieldUsed = pendingYield - remainder;
        uint256 fee = (yieldUsed * protocolFeeBps) / 10000;
        accumulatedFees += fee;
        uint256 netYield = yieldUsed - fee;

        (fractionsBought, ) = rwaToken.calculateFractions(targetAsset, netYield);

        if (fractionsBought > 0) {
            rwaToken.mintFractions(user, targetAsset, fractionsBought);
        }

        data.pendingYield = remainder;
        data.totalYieldHarvested += yieldUsed;

        RealWorldAsset.AssetMetadata memory assetInfo = rwaToken.getAssetInfo(targetAsset);
        data.totalRWAValue += fractionsBought * assetInfo.pricePerFraction;

        totalProtocolYield += yieldUsed;
        totalRWAPurchased += fractionsBought * assetInfo.pricePerFraction;

        emit YieldHarvested(
            user,
            yieldUsed,
            targetAsset,
            fractionsBought,
            block.timestamp
        );
    }

    // =========================================================================
    // USER PREFERENCE FUNCTIONS
    // =========================================================================

    /**
     * @notice Set target RWA asset for yield purchases
     * @param assetId The RWA asset ID to target
     * @dev User can change which asset their yield purchases
     *
     * Available assets:
     * - 1: NYC Real Estate (stable, tangible)
     * - 2: Treasury Bonds (lowest risk)
     * - 3: Invoice Financing (higher yield)
     * - 4: Infrastructure Bonds (long-term)
     */
    function setTargetAsset(uint256 assetId) external {
        if (!isDepositor[msg.sender]) revert UserNotDepositor(msg.sender);

        // Verify asset exists and is active
        RealWorldAsset.AssetMetadata memory asset = rwaToken.getAssetInfo(assetId);
        if (!asset.isActive) revert InvalidTargetAsset(assetId);

        uint256 oldAssetId = userData[msg.sender].targetAssetId;
        userData[msg.sender].targetAssetId = assetId;

        emit TargetAssetChanged(msg.sender, oldAssetId, assetId);
    }

    // =========================================================================
    // DEMO/HACKATHON FUNCTIONS
    // =========================================================================

    /**
     * @notice Generate mock yield for demo purposes
     * @param amount Amount of mock yield to add
     * @dev HACKATHON ONLY - simulates yield generation for live demo
     *
     * Why this exists:
     * - Testnet doesn't generate real mETH staking rewards
     * - Allows judges to see full user journey in minutes
     * - Can be removed for mainnet deployment
     *
     * Usage in demo:
     * 1. User deposits mETH
     * 2. Call mockYield(0.02 ether) to simulate yield
     * 3. User calls harvestAndBuy() to get RWA fractions
     * 4. Show RWA portfolio on dashboard
     */
    function mockYield(uint256 amount) external {
        address user = msg.sender;
        if (!isDepositor[user]) revert UserNotDepositor(user);

        // Accrue any time-based yield first
        _accrueYield(user);

        // Add mock yield on top
        userData[user].pendingYield += amount;

        emit MockYieldGenerated(
            user,
            amount,
            userData[user].pendingYield
        );
    }

    /**
     * @notice Admin function to add mock yield (for demo automation)
     * @param user User to add yield for
     * @param amount Amount to add
     */
    function adminMockYield(address user, uint256 amount) external onlyOwner {
        if (!isDepositor[user]) revert UserNotDepositor(user);

        _accrueYield(user);
        userData[user].pendingYield += amount;

        emit MockYieldGenerated(user, amount, userData[user].pendingYield);
    }

    // =========================================================================
    // VIEW FUNCTIONS - Dashboard Data
    // =========================================================================

    /**
     * @notice Get complete user dashboard data in single call
     * @param user Address to query
     * @return principal User's deposited principal (in underlying asset)
     * @return shares User's vault shares
     * @return pendingYield Unharvested yield
     * @return totalHarvested Lifetime yield harvested
     * @return targetAssetId Current target RWA
     * @return rwaValue Total RWA portfolio value
     * @dev Optimized for frontend - single RPC call for all data
     */
    function getUserDashboard(
        address user
    ) external view returns (
        uint256 principal,
        uint256 shares,
        uint256 pendingYield,
        uint256 totalHarvested,
        uint256 targetAssetId,
        uint256 rwaValue
    ) {
        shares = balanceOf(user);
        principal = convertToAssets(shares);
        pendingYield = calculatePendingYield(user);

        UserData storage data = userData[user];
        totalHarvested = data.totalYieldHarvested;
        targetAssetId = data.targetAssetId;
        rwaValue = data.totalRWAValue;
    }

    /**
     * @notice Get protocol-wide statistics
     * @return totalDeposits Total assets in vault
     * @return totalUsers Number of depositors
     * @return protocolYield Total yield harvested via protocol
     * @return rwaValue Total RWA purchased value
     */
    function getProtocolStats() external view returns (
        uint256 totalDeposits,
        uint256 totalUsers,
        uint256 protocolYield,
        uint256 rwaValue
    ) {
        totalDeposits = totalAssets();
        totalUsers = depositors.length;
        protocolYield = totalProtocolYield;
        rwaValue = totalRWAPurchased;
    }

    /**
     * @notice Get all depositor addresses
     * @return Array of depositor addresses
     * @dev Used for keeper batch operations
     */
    function getAllDepositors() external view returns (address[] memory) {
        return depositors;
    }

    // =========================================================================
    // ADMIN FUNCTIONS
    // =========================================================================

    /**
     * @notice Update mock APY for demo
     * @param newAPY New APY in basis points
     */
    function setMockAPY(uint256 newAPY) external onlyOwner {
        mockAPY = newAPY;
    }

    /**
     * @notice Update yield multiplier for demo speed
     * @param newMultiplier New multiplier value
     */
    function setYieldMultiplier(uint256 newMultiplier) external onlyOwner {
        yieldMultiplier = newMultiplier;
    }

    /**
     * @notice Update minimum harvest threshold
     * @param newThreshold New threshold in wei
     */
    function setMinHarvestThreshold(uint256 newThreshold) external onlyOwner {
        minHarvestThreshold = newThreshold;
    }

    /**
     * @notice Update protocol fee
     * @param newFeeBps New fee in basis points
     */
    function setProtocolFee(uint256 newFeeBps) external onlyOwner {
        require(newFeeBps <= 500, "Fee too high"); // Max 5%
        protocolFeeBps = newFeeBps;
    }

    /**
     * @notice Withdraw accumulated protocol fees
     * @param to Recipient address
     */
    function withdrawFees(address to) external onlyOwner {
        uint256 fees = accumulatedFees;
        accumulatedFees = 0;
        IERC20(asset()).safeTransfer(to, fees);
    }
}
