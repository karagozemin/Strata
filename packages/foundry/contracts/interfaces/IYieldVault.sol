// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IYieldVault
 * @notice Interface for the YieldVault ERC-4626 contract
 */
interface IYieldVault {
    struct UserData {
        uint256 depositTimestamp;
        uint256 lastHarvestTimestamp;
        uint256 totalYieldHarvested;
        uint256 pendingYield;
        uint256 targetAssetId;
        uint256 totalRWAValue;
    }

    function harvestAndBuy() external returns (uint256 fractionsBought, uint256 yieldUsed);

    function harvestForUser(address user) external returns (uint256 fractionsBought, uint256 yieldUsed);

    function setTargetAsset(uint256 assetId) external;

    function mockYield(uint256 amount) external;

    function calculatePendingYield(address user) external view returns (uint256);

    function getYieldProgress(
        address user
    ) external view returns (
        uint256 currentYield,
        uint256 targetPrice,
        uint256 progressBps,
        uint256 fractionsEarned
    );

    function getUserDashboard(
        address user
    ) external view returns (
        uint256 principal,
        uint256 shares,
        uint256 pendingYield,
        uint256 totalHarvested,
        uint256 targetAssetId,
        uint256 rwaValue
    );

    function getProtocolStats() external view returns (
        uint256 totalDeposits,
        uint256 totalUsers,
        uint256 protocolYield,
        uint256 rwaValue
    );

    function getAllDepositors() external view returns (address[] memory);
}
