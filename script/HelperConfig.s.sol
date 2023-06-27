// SPDX-License-Identifier: MIT

// 1. deploy mocks on local anvil change
// 2. Keep track of contract address across differnet chains
//  Sepolia Eth/USDT
//  Mainnet Eth/USDT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }

    event HelperConfig__CreatedMockVrfCoordinator(address vrfCoordinator);

    NetworkConfig public activeNetworkConfig;

    uint96 BASE_FEE = 0.25 ether;
    uint96 GAS_PRICE_LINK = 1e9;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        // } else if (block.chainid == 1) {
        // activeNetworkConfig = getMainnetEthConfig();
        // } else {
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 0,
                callbackGasLimit: 500000
            });
    }

    // function getMainnetEthConfig() public pure returns (NetworkConfig memory) {}

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinator = new VRFCoordinatorV2Mock(
            BASE_FEE,
            GAS_PRICE_LINK
        );
        vm.stopBroadcast();

        emit HelperConfig__CreatedMockVrfCoordinator(address(vrfCoordinator));

        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: address(vrfCoordinator),
                gasLane: 0x0,
                subscriptionId: 0, //our script will add this
                callbackGasLimit: 500000
            });
    }
}
