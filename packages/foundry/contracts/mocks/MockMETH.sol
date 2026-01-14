// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// =============================================================================
// MockMETH.sol - Mock mETH Token for Testnet Deployment
// Mantle Global Hackathon 2025
// =============================================================================
//
// This contract simulates Mantle's mETH (Mantle Staked ETH) for testing.
// In production, the YieldVault would use the actual mETH contract.
//
// mETH Key Properties (simulated):
// - Liquid staking derivative of ETH on Mantle
// - Earns ~4% APY from Mantle staking rewards
// - 1:1 redeemable for ETH (minus unstaking period)
// =============================================================================

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockMETH
 * @notice Mock mETH token for testnet deployments
 * @dev Includes faucet functionality for easy testing
 */
contract MockMETH is ERC20, Ownable {
    /// @notice Maximum faucet amount per call
    uint256 public constant MAX_FAUCET_AMOUNT = 100 ether;

    /// @notice Cooldown between faucet calls (1 hour)
    uint256 public constant FAUCET_COOLDOWN = 1 hours;

    /// @notice Track last faucet time per address
    mapping(address => uint256) public lastFaucetTime;

    /// @notice Emitted on faucet use
    event FaucetUsed(address indexed user, uint256 amount);

    constructor() ERC20("Mock Mantle Staked ETH", "mETH") Ownable(msg.sender) {
        // Mint initial supply to deployer for liquidity
        _mint(msg.sender, 1_000_000 ether);
    }

    /**
     * @notice Faucet function for testnet
     * @param amount Amount of mock mETH to mint (max 100)
     */
    function faucet(uint256 amount) external {
        require(amount <= MAX_FAUCET_AMOUNT, "Amount too high");
        require(
            block.timestamp >= lastFaucetTime[msg.sender] + FAUCET_COOLDOWN,
            "Cooldown active"
        );

        lastFaucetTime[msg.sender] = block.timestamp;
        _mint(msg.sender, amount);

        emit FaucetUsed(msg.sender, amount);
    }

    /**
     * @notice Admin mint for testing scenarios
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function adminMint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
