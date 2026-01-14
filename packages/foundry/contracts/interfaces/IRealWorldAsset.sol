// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRealWorldAsset
 * @notice Interface for the RealWorldAsset ERC-1155 contract
 */
interface IRealWorldAsset {
    struct AssetMetadata {
        string name;
        string symbol;
        string description;
        uint256 pricePerFraction;
        uint256 totalValue;
        uint256 totalFractions;
        string mantleDARef;
        string imageURI;
        bool isActive;
        uint256 apy;
    }

    function mintFractions(address to, uint256 assetId, uint256 amount) external;

    function calculateFractions(
        uint256 assetId,
        uint256 yieldAmount
    ) external view returns (uint256 fractions, uint256 remainder);

    function getAssetInfo(uint256 assetId) external view returns (AssetMetadata memory);

    function getAllAssetIds() external view returns (uint256[] memory);

    function getUserPortfolio(
        address user
    ) external view returns (
        uint256[] memory assetIds,
        uint256[] memory balances,
        uint256[] memory values
    );
}
