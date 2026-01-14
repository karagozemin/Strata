// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =============================================================================
// ██╗   ██╗██╗███████╗██╗     ██████╗ ██████╗ ██████╗ ██╗ ██████╗██╗  ██╗
// ╚██╗ ██╔╝██║██╔════╝██║     ██╔══██╗██╔══██╗██╔══██╗██║██╔════╝██║ ██╔╝
//  ╚████╔╝ ██║█████╗  ██║     ██║  ██║██████╔╝██████╔╝██║██║     █████╔╝
//   ╚██╔╝  ██║██╔══╝  ██║     ██║  ██║██╔══██╗██╔══██╗██║██║     ██╔═██╗
//    ██║   ██║███████╗███████╗██████╔╝██████╔╝██║  ██║██║╚██████╗██║  ██╗
//    ╚═╝   ╚═╝╚══════╝╚══════╝╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝
// =============================================================================
// RealWorldAsset.sol - Fractionalized RWA Token Contract
// Mantle Global Hackathon 2025 - RWA/RealFi Track
// =============================================================================
//
// 🏠 WHAT THIS CONTRACT DOES:
// This ERC-1155 contract represents fractionalized Real World Assets (RWAs).
// Each token ID represents a different asset class:
//   - ID 1: Premium NYC Real Estate
//   - ID 2: US Treasury Bonds
//   - ID 3: Commercial Invoice Financing
//   - ID 4: Infrastructure Project Bonds
//
// 🔑 KEY FEATURES:
// 1. Multi-asset representation via ERC-1155 standard
// 2. Metadata storage pointing to Mantle DA for legal documents
// 3. Controlled minting by authorized YieldVault contract
// 4. Asset valuation tracking for yield-to-RWA conversion
//
// 🌐 MANTLE ECOSYSTEM ALIGNMENT:
// - Leverages Mantle's low gas fees for frequent fractional purchases
// - Uses Mantle DA references for off-chain legal document storage
// - Optimized for mETH yield-driven micro-transactions
// =============================================================================

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title RealWorldAsset
 * @author YieldBrick Team - Mantle Hackathon 2025
 * @notice Fractionalized Real World Asset token using ERC-1155 standard
 * @dev Each token ID represents a different RWA class with unique pricing
 *
 * ┌─────────────────────────────────────────────────────────────────────────────┐
 * │                        ARCHITECTURE OVERVIEW                                 │
 * ├─────────────────────────────────────────────────────────────────────────────┤
 * │                                                                              │
 * │   ┌──────────────┐      ┌──────────────┐      ┌──────────────────────────┐  │
 * │   │  YieldVault  │──────│ RealWorld    │──────│    Mantle DA             │  │
 * │   │  (ERC-4626)  │ mint │ Asset        │ ref  │    (Legal Docs)          │  │
 * │   │              │──────│ (ERC-1155)   │──────│    - Property Deeds      │  │
 * │   └──────────────┘      └──────────────┘      │    - Bond Certificates   │  │
 * │         │                     │               │    - Compliance Proofs   │  │
 * │         │ deposit             │ own           └──────────────────────────┘  │
 * │         ▼                     ▼                                              │
 * │   ┌──────────────┐      ┌──────────────┐                                    │
 * │   │    User      │      │   User's     │                                    │
 * │   │   (mETH)     │      │   RWA        │                                    │
 * │   │   Principal  │      │   Portfolio  │                                    │
 * │   └──────────────┘      └──────────────┘                                    │
 * │                                                                              │
 * └─────────────────────────────────────────────────────────────────────────────┘
 */
contract RealWorldAsset is ERC1155, ERC1155Supply, AccessControl {
    using Strings for uint256;

    // =========================================================================
    // ROLES - Access Control for Security
    // =========================================================================

    /// @notice Role that allows minting new RWA tokens (assigned to YieldVault)
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Role for managing asset metadata (admin operations)
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("ASSET_MANAGER_ROLE");

    // =========================================================================
    // ASSET DEFINITIONS - Each ID represents a real-world asset class
    // =========================================================================

    /// @notice NYC Premium Real Estate - Tokenized Manhattan property
    uint256 public constant ASSET_NYC_REALESTATE = 1;

    /// @notice US Treasury Bond - Government-backed securities
    uint256 public constant ASSET_TREASURY_BOND = 2;

    /// @notice Invoice Financing - Commercial receivables
    uint256 public constant ASSET_INVOICE = 3;

    /// @notice Infrastructure Bond - Public works financing
    uint256 public constant ASSET_INFRASTRUCTURE = 4;

    // =========================================================================
    // DATA STRUCTURES - Asset metadata and pricing
    // =========================================================================

    /**
     * @notice Comprehensive metadata for each RWA
     * @dev Includes on-chain data + Mantle DA references for legal docs
     *
     * Why this structure?
     * - pricePerFraction: Enables yield-to-RWA conversion calculations
     * - totalValue: Represents the underlying asset's total valuation
     * - mantleDARef: Points to legal documents stored on Mantle DA
     * - isActive: Circuit breaker for regulatory compliance
     */
    struct AssetMetadata {
        string name;              // Human-readable asset name
        string symbol;            // Short identifier (e.g., "NYC-RE")
        string description;       // Detailed asset description
        uint256 pricePerFraction; // Price in wei for 1 fraction (18 decimals)
        uint256 totalValue;       // Total asset value in wei
        uint256 totalFractions;   // Maximum fractions available
        string mantleDARef;       // Mantle DA hash for legal documents
        string imageURI;          // IPFS/HTTP image for UI display
        bool isActive;            // Whether asset is available for purchase
        uint256 apy;              // Expected APY (basis points, 100 = 1%)
    }

    /// @notice Mapping from asset ID to its metadata
    mapping(uint256 => AssetMetadata) public assetMetadata;

    /// @notice Array of all registered asset IDs for enumeration
    uint256[] public registeredAssets;

    /// @notice Base URI for token metadata (ERC-1155 standard)
    string private _baseURI;

    // =========================================================================
    // EVENTS - For frontend tracking and indexing
    // =========================================================================

    /// @notice Emitted when a new RWA is registered
    event AssetRegistered(
        uint256 indexed assetId,
        string name,
        uint256 pricePerFraction,
        uint256 totalFractions
    );

    /// @notice Emitted when asset metadata is updated
    event AssetMetadataUpdated(uint256 indexed assetId, string field, string newValue);

    /// @notice Emitted when fractions are purchased via yield
    event FractionsPurchased(
        address indexed buyer,
        uint256 indexed assetId,
        uint256 amount,
        uint256 totalCost
    );

    /// @notice Emitted when Mantle DA reference is updated
    event MantleDARefUpdated(uint256 indexed assetId, string newRef);

    // =========================================================================
    // ERRORS - Custom errors for gas efficiency
    // =========================================================================

    error AssetNotActive(uint256 assetId);
    error AssetAlreadyExists(uint256 assetId);
    error AssetDoesNotExist(uint256 assetId);
    error InsufficientFractions(uint256 requested, uint256 available);
    error InvalidPrice();

    // =========================================================================
    // CONSTRUCTOR - Initialize with default assets
    // =========================================================================

    /**
     * @notice Deploy the RWA contract with pre-configured assets
     * @param baseURI_ Base URI for token metadata
     * @dev Sets up default asset classes representing diverse RWA portfolio
     *
     * Why these specific assets?
     * - Real Estate: Stable, tangible, high-value collateral
     * - Treasury Bonds: Risk-free rate benchmark
     * - Invoices: Short-term, high-yield opportunity
     * - Infrastructure: Long-term, stable cash flows
     */
    constructor(string memory baseURI_) ERC1155(baseURI_) {
        _baseURI = baseURI_;

        // Grant deployer all administrative roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ASSET_MANAGER_ROLE, msg.sender);

        // =====================================================================
        // Initialize Default Asset Classes
        // These represent a diversified RWA portfolio for the hackathon demo
        // =====================================================================

        // Asset 1: NYC Premium Real Estate
        // Represents fractional ownership in a Manhattan commercial property
        _registerAsset(
            ASSET_NYC_REALESTATE,
            AssetMetadata({
                name: "Manhattan Prime Tower - Floor 42",
                symbol: "NYC-RE",
                description: "Fractional ownership in premium Manhattan commercial real estate. "
                    "Property located at 350 5th Avenue with AAA tenant occupancy.",
                pricePerFraction: 0.01 ether,    // Each fraction = 0.01 ETH (~$25)
                totalValue: 10000 ether,          // Total property value: 10,000 ETH
                totalFractions: 1_000_000,        // 1M fractions available
                mantleDARef: "mantle-da://0x1234...nyc-property-deed",
                imageURI: "ipfs://QmNYCRealEstate...",
                isActive: true,
                apy: 450                          // 4.5% expected rental yield
            })
        );

        // Asset 2: US Treasury Bond
        // Represents fractional ownership in T-Bills
        _registerAsset(
            ASSET_TREASURY_BOND,
            AssetMetadata({
                name: "US Treasury Bond 2025",
                symbol: "TBOND",
                description: "Tokenized US Treasury Bond with 5.25% yield. "
                    "Government-backed, lowest risk asset class.",
                pricePerFraction: 0.001 ether,   // Lower entry point for bonds
                totalValue: 1000 ether,
                totalFractions: 1_000_000,
                mantleDARef: "mantle-da://0x5678...treasury-certificate",
                imageURI: "ipfs://QmTreasuryBond...",
                isActive: true,
                apy: 525                          // 5.25% treasury yield
            })
        );

        // Asset 3: Commercial Invoice Financing
        // Short-term, higher yield opportunity
        _registerAsset(
            ASSET_INVOICE,
            AssetMetadata({
                name: "Trade Finance Invoice Pool",
                symbol: "INVFIN",
                description: "Pool of verified commercial invoices from Fortune 500 companies. "
                    "30-90 day maturity with credit insurance.",
                pricePerFraction: 0.005 ether,
                totalValue: 5000 ether,
                totalFractions: 1_000_000,
                mantleDARef: "mantle-da://0x9ABC...invoice-pool-audit",
                imageURI: "ipfs://QmInvoicePool...",
                isActive: true,
                apy: 850                          // 8.5% invoice financing yield
            })
        );

        // Asset 4: Infrastructure Project Bond
        // Long-term sustainable investment
        _registerAsset(
            ASSET_INFRASTRUCTURE,
            AssetMetadata({
                name: "Green Energy Infrastructure Bond",
                symbol: "INFRA",
                description: "Solar and wind farm infrastructure financing. "
                    "25-year project bonds with government subsidies.",
                pricePerFraction: 0.002 ether,
                totalValue: 2000 ether,
                totalFractions: 1_000_000,
                mantleDARef: "mantle-da://0xDEF0...infrastructure-permit",
                imageURI: "ipfs://QmGreenInfra...",
                isActive: true,
                apy: 650                          // 6.5% infrastructure yield
            })
        );
    }

    // =========================================================================
    // EXTERNAL FUNCTIONS - Core protocol operations
    // =========================================================================

    /**
     * @notice Mint RWA fractions to a user (called by YieldVault)
     * @param to Recipient address
     * @param assetId The RWA asset ID to mint
     * @param amount Number of fractions to mint
     * @dev Only callable by addresses with MINTER_ROLE (YieldVault contract)
     *
     * Security considerations:
     * - Restricted to MINTER_ROLE to prevent unauthorized minting
     * - Checks asset is active (regulatory compliance)
     * - Validates sufficient fractions remain
     */
    function mintFractions(
        address to,
        uint256 assetId,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) {
        AssetMetadata storage asset = assetMetadata[assetId];

        // Validate asset exists and is active
        if (!asset.isActive) revert AssetNotActive(assetId);

        // Check available supply
        uint256 currentSupply = totalSupply(assetId);
        if (currentSupply + amount > asset.totalFractions) {
            revert InsufficientFractions(amount, asset.totalFractions - currentSupply);
        }

        // Mint fractions to user
        _mint(to, assetId, amount, "");

        emit FractionsPurchased(to, assetId, amount, amount * asset.pricePerFraction);
    }

    /**
     * @notice Calculate how many fractions can be bought with given yield
     * @param assetId The target RWA asset
     * @param yieldAmount Amount of yield in wei
     * @return fractions Number of whole fractions purchasable
     * @return remainder Leftover yield after purchase
     * @dev Used by YieldVault to determine purchase amounts
     *
     * Example:
     * - Yield = 0.025 ETH
     * - Asset price = 0.01 ETH per fraction
     * - Result: 2 fractions, 0.005 ETH remainder
     */
    function calculateFractions(
        uint256 assetId,
        uint256 yieldAmount
    ) external view returns (uint256 fractions, uint256 remainder) {
        AssetMetadata storage asset = assetMetadata[assetId];
        if (asset.pricePerFraction == 0) revert InvalidPrice();

        fractions = yieldAmount / asset.pricePerFraction;
        remainder = yieldAmount % asset.pricePerFraction;
    }

    /**
     * @notice Get comprehensive asset information
     * @param assetId The asset ID to query
     * @return Full AssetMetadata struct
     */
    function getAssetInfo(uint256 assetId) external view returns (AssetMetadata memory) {
        return assetMetadata[assetId];
    }

    /**
     * @notice Get all registered asset IDs
     * @return Array of asset IDs for frontend enumeration
     */
    function getAllAssetIds() external view returns (uint256[] memory) {
        return registeredAssets;
    }

    /**
     * @notice Get user's complete RWA portfolio
     * @param user Address to query
     * @return assetIds Array of asset IDs user owns
     * @return balances Corresponding balances for each asset
     * @return values USD value of each holding (based on fraction price)
     */
    function getUserPortfolio(
        address user
    ) external view returns (
        uint256[] memory assetIds,
        uint256[] memory balances,
        uint256[] memory values
    ) {
        uint256 length = registeredAssets.length;
        assetIds = new uint256[](length);
        balances = new uint256[](length);
        values = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            uint256 assetId = registeredAssets[i];
            assetIds[i] = assetId;
            balances[i] = balanceOf(user, assetId);
            values[i] = balances[i] * assetMetadata[assetId].pricePerFraction;
        }
    }

    // =========================================================================
    // ADMIN FUNCTIONS - Asset management
    // =========================================================================

    /**
     * @notice Register a new RWA asset class
     * @param assetId Unique identifier for the asset
     * @param metadata Complete asset metadata
     * @dev Only callable by ASSET_MANAGER_ROLE
     */
    function registerAsset(
        uint256 assetId,
        AssetMetadata calldata metadata
    ) external onlyRole(ASSET_MANAGER_ROLE) {
        _registerAsset(assetId, metadata);
    }

    /**
     * @notice Update Mantle DA reference for legal documents
     * @param assetId Asset to update
     * @param newRef New Mantle DA hash
     * @dev Used when legal documents are updated/renewed
     */
    function updateMantleDARef(
        uint256 assetId,
        string calldata newRef
    ) external onlyRole(ASSET_MANAGER_ROLE) {
        if (bytes(assetMetadata[assetId].name).length == 0) {
            revert AssetDoesNotExist(assetId);
        }
        assetMetadata[assetId].mantleDARef = newRef;
        emit MantleDARefUpdated(assetId, newRef);
    }

    /**
     * @notice Toggle asset active status (regulatory compliance)
     * @param assetId Asset to toggle
     * @param isActive New active status
     */
    function setAssetActive(
        uint256 assetId,
        bool isActive
    ) external onlyRole(ASSET_MANAGER_ROLE) {
        if (bytes(assetMetadata[assetId].name).length == 0) {
            revert AssetDoesNotExist(assetId);
        }
        assetMetadata[assetId].isActive = isActive;
    }

    /**
     * @notice Grant minting rights to YieldVault contract
     * @param vault Address of the YieldVault contract
     * @dev Called once during deployment to authorize vault
     */
    function setVaultAsMinter(address vault) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, vault);
    }

    // =========================================================================
    // INTERNAL FUNCTIONS
    // =========================================================================

    /**
     * @notice Internal asset registration logic
     * @param assetId Asset ID to register
     * @param metadata Asset metadata to store
     */
    function _registerAsset(uint256 assetId, AssetMetadata memory metadata) internal {
        if (bytes(assetMetadata[assetId].name).length != 0) {
            revert AssetAlreadyExists(assetId);
        }

        assetMetadata[assetId] = metadata;
        registeredAssets.push(assetId);

        emit AssetRegistered(
            assetId,
            metadata.name,
            metadata.pricePerFraction,
            metadata.totalFractions
        );
    }

    // =========================================================================
    // OVERRIDES - Required by Solidity for multiple inheritance
    // =========================================================================

    /**
     * @notice URI for token metadata (ERC-1155 standard)
     * @param tokenId The token ID to get URI for
     * @return URI string pointing to metadata JSON
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(_baseURI, tokenId.toString(), ".json"));
    }

    /**
     * @dev Required override for ERC1155Supply
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    /**
     * @dev Required override for AccessControl + ERC1155
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
