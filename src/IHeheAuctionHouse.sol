// SPDX-License-Identifier: GPL-3.0
// @title Auction House for Doge-Hehe

pragma solidity ^0.8.4;

interface IHeheAuctionHouse {
    struct HeheAuctionHouse {
        // ID of the Hehe token currently up for auction - ERC721
        uint256 heheId;
        // current highest bid made
        uint256 bidAmount;
        // start time for the auction of the token
        uint256 startTime;
        // end time for the auction of the token
        uint256 endTime;
        // address of the current highest bidder to send the Hehe to
        address payable bidder;
        // signifies the end of the auction
        bool auctionSettled;
    }

    event AuctionCreated(
        uint256 indexed heheId,
        uint256 startTime,
        uint256 endTime
    );

    event AuctionBid(uint256 indexed heheId, address sender, uint256 value);

    event AuctionSettled(
        uint256 indexed heheId,
        address winner,
        uint256 amount
    );

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(
        uint256 minBidIncrementPercentage
    );

    function createAuction() external;

    function settleAuction() external;

    function settleCurrentAndCreateNewAuction() external;

    function createBid(uint256 nounId) external payable;
}
