// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    //immutable only initialized inline or in constructor
    address private immutable owner;
    AggregatorV3Interface private immutable priceFeed;

    constructor(address _priceFeed) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getVersion() public view returns (uint256) {
        return PriceConverter.getVersion(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) > MINIMUM_USD,
            "did not send enough funds"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        //transfer, throws error if something
        // payable(msg.sender).transfer(address(this).balance);
        //send, returns boolean indicating success
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            // takes less gas than require
            revert NotOwner();
        }
        _;
    }

    // for data sent with no calldata, calls fallback when not found
    receive() external payable {
        fund();
    }

    // for data sent with calldata not matching an existing function
    fallback() external payable {
        fund();
    }

    //GETTERS

    function getFunderByIndex(uint index) external view returns (address) {
        return s_funders[index];
    }

    function getAmountFunded(address funder) external view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
