// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Sepolia ETH/USD address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
// ZKSync ETH/USD address: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 private constant DECIMALS = 8;
    int256 private constant INITIAL_PRICE = 20000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 300) {
            activeNetworkConfig = getZkSyncEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    // not working for now
    function getZkSyncEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        return NetworkConfig(address(mockPriceFeed));
    }
}
