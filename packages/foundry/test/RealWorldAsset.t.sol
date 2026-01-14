// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// =============================================================================
// RealWorldAsset.t.sol - ERC-1155 RWA Token Test Suite
// Mantle Global Hackathon 2025
// =============================================================================

import "forge-std/Test.sol";
import "../contracts/RealWorldAsset.sol";

contract RealWorldAssetTest is Test {
    RealWorldAsset public rwaToken;

    address public deployer = address(1);
    address public vault = address(2);
    address public alice = address(3);
    address public bob = address(4);

    // Asset IDs
    uint256 constant NYC_REALESTATE = 1;
    uint256 constant TREASURY_BOND = 2;
    uint256 constant INVOICE = 3;
    uint256 constant INFRASTRUCTURE = 4;

    function setUp() public {
        vm.startPrank(deployer);
        rwaToken = new RealWorldAsset("https://api.strata.xyz/metadata/");
        
        // Set vault as minter
        rwaToken.setVaultAsMinter(vault);
        vm.stopPrank();
    }

    // =========================================================================
    // INITIALIZATION TESTS
    // =========================================================================

    function test_InitialAssets() public view {
        // Check all 4 default assets are registered
        uint256[] memory assetIds = rwaToken.getAllAssetIds();
        assertEq(assetIds.length, 4, "Should have 4 default assets");
        
        assertEq(assetIds[0], NYC_REALESTATE, "Asset 1 should be NYC Real Estate");
        assertEq(assetIds[1], TREASURY_BOND, "Asset 2 should be Treasury Bond");
        assertEq(assetIds[2], INVOICE, "Asset 3 should be Invoice");
        assertEq(assetIds[3], INFRASTRUCTURE, "Asset 4 should be Infrastructure");
    }

    function test_AssetMetadata() public view {
        RealWorldAsset.AssetMetadata memory nyc = rwaToken.getAssetInfo(NYC_REALESTATE);
        
        assertEq(nyc.symbol, "NYC-RE", "NYC symbol should be NYC-RE");
        assertEq(nyc.pricePerFraction, 0.01 ether, "NYC price should be 0.01 ETH");
        assertEq(nyc.apy, 450, "NYC APY should be 4.5%");
        assertTrue(nyc.isActive, "NYC should be active");
    }

    function test_AllAssetPrices() public view {
        RealWorldAsset.AssetMetadata memory nyc = rwaToken.getAssetInfo(NYC_REALESTATE);
        RealWorldAsset.AssetMetadata memory bond = rwaToken.getAssetInfo(TREASURY_BOND);
        RealWorldAsset.AssetMetadata memory invoice = rwaToken.getAssetInfo(INVOICE);
        RealWorldAsset.AssetMetadata memory infra = rwaToken.getAssetInfo(INFRASTRUCTURE);

        assertEq(nyc.pricePerFraction, 0.01 ether, "NYC price");
        assertEq(bond.pricePerFraction, 0.001 ether, "Bond price");
        assertEq(invoice.pricePerFraction, 0.005 ether, "Invoice price");
        assertEq(infra.pricePerFraction, 0.002 ether, "Infrastructure price");
    }

    // =========================================================================
    // MINTING TESTS
    // =========================================================================

    function test_MintFractions() public {
        vm.prank(vault);
        rwaToken.mintFractions(alice, NYC_REALESTATE, 10);

        assertEq(rwaToken.balanceOf(alice, NYC_REALESTATE), 10, "Should have 10 NYC fractions");
    }

    function test_MintMultipleAssets() public {
        vm.startPrank(vault);
        rwaToken.mintFractions(alice, NYC_REALESTATE, 5);
        rwaToken.mintFractions(alice, TREASURY_BOND, 100);
        rwaToken.mintFractions(alice, INVOICE, 20);
        vm.stopPrank();

        assertEq(rwaToken.balanceOf(alice, NYC_REALESTATE), 5, "NYC balance");
        assertEq(rwaToken.balanceOf(alice, TREASURY_BOND), 100, "Bond balance");
        assertEq(rwaToken.balanceOf(alice, INVOICE), 20, "Invoice balance");
    }

    function test_MintOnlyByMinter() public {
        vm.prank(alice);
        vm.expectRevert();
        rwaToken.mintFractions(alice, NYC_REALESTATE, 10);
    }

    function test_CannotMintInactiveAsset() public {
        // Deactivate asset
        vm.prank(deployer);
        rwaToken.setAssetActive(NYC_REALESTATE, false);

        // Try to mint
        vm.prank(vault);
        vm.expectRevert(abi.encodeWithSelector(RealWorldAsset.AssetNotActive.selector, NYC_REALESTATE));
        rwaToken.mintFractions(alice, NYC_REALESTATE, 10);
    }

    // =========================================================================
    // FRACTION CALCULATION TESTS
    // =========================================================================

    function test_CalculateFractions() public view {
        uint256 yieldAmount = 0.025 ether;
        
        (uint256 fractions, uint256 remainder) = rwaToken.calculateFractions(NYC_REALESTATE, yieldAmount);
        
        // NYC price is 0.01 ETH, so 0.025 ETH = 2 fractions + 0.005 remainder
        assertEq(fractions, 2, "Should calculate 2 fractions");
        assertEq(remainder, 0.005 ether, "Should have 0.005 ETH remainder");
    }

    function test_CalculateFractionsExact() public view {
        uint256 yieldAmount = 0.03 ether;
        
        (uint256 fractions, uint256 remainder) = rwaToken.calculateFractions(NYC_REALESTATE, yieldAmount);
        
        assertEq(fractions, 3, "Should calculate 3 fractions");
        assertEq(remainder, 0, "Should have no remainder");
    }

    function test_CalculateFractionsInsufficient() public view {
        uint256 yieldAmount = 0.005 ether; // Less than one NYC fraction
        
        (uint256 fractions, uint256 remainder) = rwaToken.calculateFractions(NYC_REALESTATE, yieldAmount);
        
        assertEq(fractions, 0, "Should calculate 0 fractions");
        assertEq(remainder, 0.005 ether, "All should be remainder");
    }

    function test_CalculateFractionsDifferentAssets() public view {
        uint256 yieldAmount = 0.01 ether;
        
        // NYC: 0.01 ETH per fraction
        (uint256 nycFractions, ) = rwaToken.calculateFractions(NYC_REALESTATE, yieldAmount);
        assertEq(nycFractions, 1, "Should get 1 NYC fraction");
        
        // Bond: 0.001 ETH per fraction
        (uint256 bondFractions, ) = rwaToken.calculateFractions(TREASURY_BOND, yieldAmount);
        assertEq(bondFractions, 10, "Should get 10 bond fractions");
        
        // Invoice: 0.005 ETH per fraction
        (uint256 invoiceFractions, ) = rwaToken.calculateFractions(INVOICE, yieldAmount);
        assertEq(invoiceFractions, 2, "Should get 2 invoice fractions");
    }

    // =========================================================================
    // PORTFOLIO TESTS
    // =========================================================================

    function test_UserPortfolio() public {
        vm.startPrank(vault);
        rwaToken.mintFractions(alice, NYC_REALESTATE, 10);
        rwaToken.mintFractions(alice, TREASURY_BOND, 50);
        vm.stopPrank();

        (
            uint256[] memory assetIds,
            uint256[] memory balances,
            uint256[] memory values
        ) = rwaToken.getUserPortfolio(alice);

        // Check NYC Real Estate (index 0)
        assertEq(assetIds[0], NYC_REALESTATE, "First asset should be NYC");
        assertEq(balances[0], 10, "Should have 10 NYC fractions");
        assertEq(values[0], 10 * 0.01 ether, "NYC value should be 0.1 ETH");

        // Check Treasury Bond (index 1)
        assertEq(assetIds[1], TREASURY_BOND, "Second asset should be Bond");
        assertEq(balances[1], 50, "Should have 50 bond fractions");
        assertEq(values[1], 50 * 0.001 ether, "Bond value should be 0.05 ETH");
    }

    function test_EmptyPortfolio() public view {
        (
            uint256[] memory assetIds,
            uint256[] memory balances,
            uint256[] memory values
        ) = rwaToken.getUserPortfolio(alice);

        assertEq(assetIds.length, 4, "Should return all 4 assets");
        
        for (uint256 i = 0; i < balances.length; i++) {
            assertEq(balances[i], 0, "All balances should be 0");
            assertEq(values[i], 0, "All values should be 0");
        }
    }

    // =========================================================================
    // ADMIN TESTS
    // =========================================================================

    function test_RegisterNewAsset() public {
        vm.prank(deployer);
        rwaToken.registerAsset(
            5, // New asset ID
            RealWorldAsset.AssetMetadata({
                name: "Art Collection Fund",
                symbol: "ART",
                description: "Tokenized fine art collection",
                pricePerFraction: 0.05 ether,
                totalValue: 5000 ether,
                totalFractions: 100_000,
                mantleDARef: "mantle-da://0xART...art-provenance",
                imageURI: "ipfs://QmArtCollection...",
                isActive: true,
                apy: 300
            })
        );

        uint256[] memory assetIds = rwaToken.getAllAssetIds();
        assertEq(assetIds.length, 5, "Should have 5 assets now");
        
        RealWorldAsset.AssetMetadata memory art = rwaToken.getAssetInfo(5);
        assertEq(art.symbol, "ART", "New asset symbol should be ART");
    }

    function test_CannotRegisterDuplicateAsset() public {
        vm.prank(deployer);
        vm.expectRevert(abi.encodeWithSelector(RealWorldAsset.AssetAlreadyExists.selector, NYC_REALESTATE));
        rwaToken.registerAsset(
            NYC_REALESTATE,
            RealWorldAsset.AssetMetadata({
                name: "Duplicate",
                symbol: "DUP",
                description: "Should fail",
                pricePerFraction: 0.01 ether,
                totalValue: 1000 ether,
                totalFractions: 100_000,
                mantleDARef: "",
                imageURI: "",
                isActive: true,
                apy: 100
            })
        );
    }

    function test_UpdateMantleDARef() public {
        string memory newRef = "mantle-da://0xNEW...updated-deed";
        
        vm.prank(deployer);
        rwaToken.updateMantleDARef(NYC_REALESTATE, newRef);
        
        RealWorldAsset.AssetMetadata memory nyc = rwaToken.getAssetInfo(NYC_REALESTATE);
        assertEq(nyc.mantleDARef, newRef, "Mantle DA ref should be updated");
    }

    function test_ToggleAssetActive() public {
        // Deactivate
        vm.prank(deployer);
        rwaToken.setAssetActive(NYC_REALESTATE, false);
        
        RealWorldAsset.AssetMetadata memory nyc = rwaToken.getAssetInfo(NYC_REALESTATE);
        assertFalse(nyc.isActive, "Asset should be inactive");
        
        // Reactivate
        vm.prank(deployer);
        rwaToken.setAssetActive(NYC_REALESTATE, true);
        
        nyc = rwaToken.getAssetInfo(NYC_REALESTATE);
        assertTrue(nyc.isActive, "Asset should be active again");
    }

    // =========================================================================
    // TRANSFER TESTS
    // =========================================================================

    function test_TransferFractions() public {
        vm.prank(vault);
        rwaToken.mintFractions(alice, NYC_REALESTATE, 10);

        vm.prank(alice);
        rwaToken.safeTransferFrom(alice, bob, NYC_REALESTATE, 5, "");

        assertEq(rwaToken.balanceOf(alice, NYC_REALESTATE), 5, "Alice should have 5");
        assertEq(rwaToken.balanceOf(bob, NYC_REALESTATE), 5, "Bob should have 5");
    }

    function test_BatchTransfer() public {
        vm.startPrank(vault);
        rwaToken.mintFractions(alice, NYC_REALESTATE, 10);
        rwaToken.mintFractions(alice, TREASURY_BOND, 20);
        vm.stopPrank();

        uint256[] memory ids = new uint256[](2);
        ids[0] = NYC_REALESTATE;
        ids[1] = TREASURY_BOND;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 5;
        amounts[1] = 10;

        vm.prank(alice);
        rwaToken.safeBatchTransferFrom(alice, bob, ids, amounts, "");

        assertEq(rwaToken.balanceOf(bob, NYC_REALESTATE), 5, "Bob NYC balance");
        assertEq(rwaToken.balanceOf(bob, TREASURY_BOND), 10, "Bob Bond balance");
    }

    // =========================================================================
    // URI TESTS
    // =========================================================================

    function test_TokenURI() public view {
        string memory uri1 = rwaToken.uri(NYC_REALESTATE);
        assertEq(uri1, "https://api.strata.xyz/metadata/1.json", "URI should match");
        
        string memory uri2 = rwaToken.uri(TREASURY_BOND);
        assertEq(uri2, "https://api.strata.xyz/metadata/2.json", "URI should match");
    }

    // =========================================================================
    // SUPPLY TESTS
    // =========================================================================

    function test_TotalSupply() public {
        vm.startPrank(vault);
        rwaToken.mintFractions(alice, NYC_REALESTATE, 100);
        rwaToken.mintFractions(bob, NYC_REALESTATE, 50);
        vm.stopPrank();

        assertEq(rwaToken.totalSupply(NYC_REALESTATE), 150, "Total supply should be 150");
    }

    function test_CannotExceedMaxSupply() public {
        RealWorldAsset.AssetMetadata memory nyc = rwaToken.getAssetInfo(NYC_REALESTATE);
        
        vm.prank(vault);
        vm.expectRevert(
            abi.encodeWithSelector(
                RealWorldAsset.InsufficientFractions.selector,
                nyc.totalFractions + 1,
                nyc.totalFractions
            )
        );
        rwaToken.mintFractions(alice, NYC_REALESTATE, nyc.totalFractions + 1);
    }
}
