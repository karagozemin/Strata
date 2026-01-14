// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =============================================================================
// YieldVault.t.sol - Test Suite for Strata Protocol
// Mantle Global Hackathon 2025
// =============================================================================

import "forge-std/Test.sol";
import "../contracts/RealWorldAsset.sol";
import "../contracts/YieldVault.sol";
import "../contracts/mocks/MockMETH.sol";

contract YieldVaultTest is Test {
    MockMETH public mETH;
    RealWorldAsset public rwaToken;
    YieldVault public vault;

    address public deployer = address(1);
    address public alice = address(2);
    address public bob = address(3);

    uint256 constant INITIAL_BALANCE = 100 ether;

    function setUp() public {
        vm.startPrank(deployer);

        // Deploy contracts
        mETH = new MockMETH();
        rwaToken = new RealWorldAsset("https://api.Strata.xyz/metadata/");
        vault = new YieldVault(
            IERC20(address(mETH)),
            rwaToken,
            "Strata mETH Vault",
            "ybMETH"
        );

        // Configure permissions
        rwaToken.setVaultAsMinter(address(vault));

        // Set high yield multiplier for testing
        vault.setYieldMultiplier(10000);
        vault.setMinHarvestThreshold(0.00001 ether);

        // Fund test accounts
        mETH.adminMint(alice, INITIAL_BALANCE);
        mETH.adminMint(bob, INITIAL_BALANCE);

        vm.stopPrank();
    }

    // =========================================================================
    // DEPOSIT TESTS
    // =========================================================================

    function test_Deposit() public {
        uint256 depositAmount = 10 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount, alice);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), shares, "Should receive shares");
        assertEq(mETH.balanceOf(address(vault)), depositAmount, "Vault should hold mETH");
        assertTrue(vault.isDepositor(alice), "Should be marked as depositor");
    }

    function test_DepositInitializesUserData() public {
        uint256 depositAmount = 10 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);
        vm.stopPrank();

        (
            uint256 principal,
            uint256 shares,
            uint256 pendingYield,
            uint256 totalHarvested,
            uint256 targetAssetId,
            uint256 rwaValue
        ) = vault.getUserDashboard(alice);

        assertEq(principal, depositAmount, "Principal should match deposit");
        assertGt(shares, 0, "Should have shares");
        assertEq(pendingYield, 0, "Initial pending yield should be 0");
        assertEq(totalHarvested, 0, "No harvests yet");
        assertEq(targetAssetId, 1, "Default target should be asset 1");
        assertEq(rwaValue, 0, "No RWA value yet");
    }

    // =========================================================================
    // YIELD ACCRUAL TESTS
    // =========================================================================

    function test_YieldAccruesOverTime() public {
        uint256 depositAmount = 10 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);
        vm.stopPrank();

        // Advance time by 1 day
        vm.warp(block.timestamp + 1 days);

        uint256 pendingYield = vault.calculatePendingYield(alice);
        assertGt(pendingYield, 0, "Yield should accrue over time");
    }

    function test_MockYieldFunction() public {
        uint256 depositAmount = 10 ether;
        uint256 mockYieldAmount = 0.5 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);

        // Add mock yield
        vault.mockYield(mockYieldAmount);
        vm.stopPrank();

        uint256 pendingYield = vault.calculatePendingYield(alice);
        assertGe(pendingYield, mockYieldAmount, "Mock yield should be added");
    }

    // =========================================================================
    // HARVEST AND BUY TESTS
    // =========================================================================

    function test_HarvestAndBuy() public {
        uint256 depositAmount = 10 ether;
        uint256 mockYieldAmount = 0.05 ether; // Enough for 5 NYC fractions at 0.01 ETH each

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);

        // Add mock yield
        vault.mockYield(mockYieldAmount);

        // Harvest and buy RWA
        (uint256 fractionsBought, uint256 yieldUsed) = vault.harvestAndBuy();
        vm.stopPrank();

        assertGt(fractionsBought, 0, "Should buy fractions");
        assertGt(yieldUsed, 0, "Should use yield");

        // Check RWA balance
        uint256 rwaBalance = rwaToken.balanceOf(alice, 1); // Asset ID 1 (NYC Real Estate)
        assertEq(rwaBalance, fractionsBought, "Should own RWA fractions");
    }

    function test_HarvestUpdatesUserStats() public {
        uint256 depositAmount = 10 ether;
        uint256 mockYieldAmount = 0.05 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);
        vault.mockYield(mockYieldAmount);
        vault.harvestAndBuy();
        vm.stopPrank();

        (
            ,
            ,
            ,
            uint256 totalHarvested,
            ,
            uint256 rwaValue
        ) = vault.getUserDashboard(alice);

        assertGt(totalHarvested, 0, "Should track harvested yield");
        assertGt(rwaValue, 0, "Should track RWA value");
    }

    // =========================================================================
    // TARGET ASSET TESTS
    // =========================================================================

    function test_ChangeTargetAsset() public {
        uint256 depositAmount = 10 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);

        // Change target to Treasury Bonds (ID 2)
        vault.setTargetAsset(2);
        vm.stopPrank();

        (, , , , uint256 targetAssetId, ) = vault.getUserDashboard(alice);
        assertEq(targetAssetId, 2, "Target should be Treasury Bonds");
    }

    function test_BuyDifferentAssets() public {
        uint256 depositAmount = 10 ether;
        uint256 mockYieldAmount = 0.01 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);

        // Buy NYC Real Estate (default target)
        vault.mockYield(mockYieldAmount);
        vault.harvestAndBuy();

        // Change target to Treasury Bonds
        vault.setTargetAsset(2);
        vault.mockYield(mockYieldAmount);
        vault.harvestAndBuy();

        vm.stopPrank();

        // Should own both assets
        uint256 nycBalance = rwaToken.balanceOf(alice, 1);
        uint256 bondBalance = rwaToken.balanceOf(alice, 2);

        assertGt(nycBalance, 0, "Should own NYC fractions");
        assertGt(bondBalance, 0, "Should own Bond fractions");
    }

    // =========================================================================
    // YIELD PROGRESS TESTS
    // =========================================================================

    function test_YieldProgress() public {
        uint256 depositAmount = 10 ether;
        uint256 mockYieldAmount = 0.005 ether; // 50% of one fraction

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);
        vault.mockYield(mockYieldAmount);
        vm.stopPrank();

        (
            uint256 currentYield,
            uint256 targetPrice,
            uint256 progressBps,
            uint256 fractionsEarned
        ) = vault.getYieldProgress(alice);

        assertEq(targetPrice, 0.01 ether, "NYC fraction price is 0.01 ETH");
        assertGe(progressBps, 4900, "Should be ~50% progress");
        assertEq(fractionsEarned, 0, "Not enough for 1 fraction yet");
    }

    // =========================================================================
    // PORTFOLIO TESTS
    // =========================================================================

    function test_UserPortfolio() public {
        uint256 depositAmount = 10 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);

        // Buy multiple assets
        vault.mockYield(0.02 ether);
        vault.harvestAndBuy(); // NYC Real Estate

        vault.setTargetAsset(2);
        vault.mockYield(0.01 ether);
        vault.harvestAndBuy(); // Treasury Bonds

        vault.setTargetAsset(3);
        vault.mockYield(0.01 ether);
        vault.harvestAndBuy(); // Invoice Financing

        vm.stopPrank();

        // Get portfolio
        (
            uint256[] memory assetIds,
            uint256[] memory balances,
            uint256[] memory values
        ) = rwaToken.getUserPortfolio(alice);

        uint256 totalValue = 0;
        for (uint256 i = 0; i < assetIds.length; i++) {
            totalValue += values[i];
        }

        assertGt(totalValue, 0, "Should have RWA portfolio value");
    }

    // =========================================================================
    // PROTOCOL STATS TESTS
    // =========================================================================

    function test_ProtocolStats() public {
        // Alice deposits and harvests
        vm.startPrank(alice);
        mETH.approve(address(vault), 10 ether);
        vault.deposit(10 ether, alice);
        vault.mockYield(0.05 ether);
        vault.harvestAndBuy();
        vm.stopPrank();

        // Bob deposits and harvests
        vm.startPrank(bob);
        mETH.approve(address(vault), 20 ether);
        vault.deposit(20 ether, bob);
        vault.mockYield(0.1 ether);
        vault.harvestAndBuy();
        vm.stopPrank();

        (
            uint256 totalDeposits,
            uint256 totalUsers,
            uint256 protocolYield,
            uint256 rwaValue
        ) = vault.getProtocolStats();

        assertEq(totalDeposits, 30 ether, "Total deposits should be 30 ETH");
        assertEq(totalUsers, 2, "Should have 2 users");
        assertGt(protocolYield, 0, "Should track protocol yield");
        assertGt(rwaValue, 0, "Should track RWA value");
    }

    // =========================================================================
    // WITHDRAWAL TESTS
    // =========================================================================

    function test_WithdrawPrincipal() public {
        uint256 depositAmount = 10 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);

        // Advance time to accrue some yield
        vm.warp(block.timestamp + 1 days);

        // Withdraw all
        uint256 shares = vault.balanceOf(alice);
        vault.redeem(shares, alice, alice);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 0, "Should have no shares");
        assertGe(mETH.balanceOf(alice), INITIAL_BALANCE, "Should have original balance back");
    }

    function test_PartialWithdraw() public {
        uint256 depositAmount = 10 ether;

        vm.startPrank(alice);
        mETH.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, alice);

        // Withdraw half
        vault.withdraw(5 ether, alice, alice);
        vm.stopPrank();

        uint256 remaining = vault.convertToAssets(vault.balanceOf(alice));
        assertEq(remaining, 5 ether, "Should have half remaining");
    }
}
