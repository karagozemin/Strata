// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =============================================================================
// Deploy.s.sol - Strata Deployment Script for Mantle Network
// Mantle Global Hackathon 2025
// =============================================================================
//
// Deployment Order:
// 1. MockMETH (testnet only) - simulates mETH token
// 2. RealWorldAsset - ERC-1155 for fractionalized RWAs
// 3. YieldVault - ERC-4626 vault with yield-to-RWA logic
// 4. Configure permissions (grant MINTER_ROLE to vault)
//
// Networks:
// - Mantle Testnet Sepolia: https://rpc.sepolia.mantle.xyz (Chain ID: 5003)
// - Mantle Mainnet: https://rpc.mantle.xyz (Chain ID: 5000)
// =============================================================================

import "forge-std/Script.sol";
import "../contracts/RealWorldAsset.sol";
import "../contracts/YieldVault.sol";
import "../contracts/mocks/MockMETH.sol";

contract DeployStrata is Script {
    // Deployed contract addresses (set after deployment)
    MockMETH public mockMETH;
    RealWorldAsset public rwaToken;
    YieldVault public yieldVault;

    function run() external {
        // Load private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("==============================================");
        console.log("Strata Deployment - Mantle Network");
        console.log("==============================================");
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        // =====================================================================
        // Step 1: Deploy Mock mETH (testnet only)
        // =====================================================================
        console.log("1. Deploying MockMETH...");
        mockMETH = new MockMETH();
        console.log("   MockMETH deployed at:", address(mockMETH));

        // =====================================================================
        // Step 2: Deploy RealWorldAsset (ERC-1155)
        // =====================================================================
        console.log("2. Deploying RealWorldAsset...");
        string memory baseURI = "https://api.Strata.xyz/metadata/";
        rwaToken = new RealWorldAsset(baseURI);
        console.log("   RealWorldAsset deployed at:", address(rwaToken));

        // =====================================================================
        // Step 3: Deploy YieldVault (ERC-4626)
        // =====================================================================
        console.log("3. Deploying YieldVault...");
        yieldVault = new YieldVault(
            IERC20(address(mockMETH)),
            rwaToken,
            "Strata mETH Vault",
            "ybMETH"
        );
        console.log("   YieldVault deployed at:", address(yieldVault));

        // =====================================================================
        // Step 4: Configure Permissions
        // =====================================================================
        console.log("4. Configuring permissions...");
        rwaToken.setVaultAsMinter(address(yieldVault));
        console.log("   Granted MINTER_ROLE to YieldVault");

        // =====================================================================
        // Step 5: Initial Setup for Demo
        // =====================================================================
        console.log("5. Setting up demo configuration...");

        // Set yield multiplier high for demo (yields accumulate faster)
        yieldVault.setYieldMultiplier(1000); // 1000x faster for demo
        console.log("   Yield multiplier set to 1000x");

        // Lower harvest threshold for demo
        yieldVault.setMinHarvestThreshold(0.0001 ether);
        console.log("   Min harvest threshold: 0.0001 ETH");

        vm.stopBroadcast();

        // =====================================================================
        // Deployment Summary
        // =====================================================================
        console.log("");
        console.log("==============================================");
        console.log("DEPLOYMENT COMPLETE!");
        console.log("==============================================");
        console.log("");
        console.log("Contract Addresses:");
        console.log("-------------------");
        console.log("MockMETH:        ", address(mockMETH));
        console.log("RealWorldAsset:  ", address(rwaToken));
        console.log("YieldVault:      ", address(yieldVault));
        console.log("");
        console.log("Next Steps:");
        console.log("-----------");
        console.log("1. Update frontend with contract addresses");
        console.log("2. Call mockMETH.faucet(10 ether) to get test tokens");
        console.log("3. Approve YieldVault to spend mETH");
        console.log("4. Deposit mETH into YieldVault");
        console.log("5. Call mockYield() or wait for yield to accrue");
        console.log("6. Call harvestAndBuy() to convert yield to RWA");
        console.log("");
        console.log("Verify on Mantle Explorer:");
        console.log("https://explorer.sepolia.mantle.xyz");
    }
}

// =============================================================================
// Individual Deployment Scripts (for modular deployment)
// =============================================================================

contract DeployMockMETH is Script {
    function run() external returns (MockMETH) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MockMETH mockMETH = new MockMETH();

        vm.stopBroadcast();
        console.log("MockMETH deployed at:", address(mockMETH));
        return mockMETH;
    }
}

contract DeployRWA is Script {
    function run() external returns (RealWorldAsset) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        RealWorldAsset rwa = new RealWorldAsset("https://api.Strata.xyz/metadata/");

        vm.stopBroadcast();
        console.log("RealWorldAsset deployed at:", address(rwa));
        return rwa;
    }
}
