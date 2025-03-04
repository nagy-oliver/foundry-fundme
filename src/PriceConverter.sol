// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (uint256) {
        // address conversionAddress = 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF; //zksync
        address conversionAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306; //sepolia
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            conversionAddress
        );
        (, int price, , , ) = priceFeed.latestRoundData();
        // has 8 decimals, shown as integer, 10 more need to be added to make it have 18 decimal places
        return uint256(price) * 1e10;
    }

    function getConversionRate(
        uint256 ethAmount
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        // address conversionAddress = 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF;
        address conversionAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        return AggregatorV3Interface(conversionAddress).version();
    }
}
