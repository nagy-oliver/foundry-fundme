// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded)
        public addressToAmountFunded;

    //immutable only initialized inline or in constructor
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function getVersion() public view returns (uint256) {
        return PriceConverter.getVersion();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate() > MINIMUM_USD,
            "did not send enough funds"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function widthdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

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
}
