// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IHeheAuctionHouse} from "./interfaces/IHeheAuctionHouse.sol";
import {INFT} from "./interfaces/INFT.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

contract HeheAuctionHouse is
    Pausable,
    Ownable,
    ReentrancyGuard,
    IERC721Receiver
{
    using SafeMath for uint256;

    address payable private contractOwner;
    INFT public hehe;
    uint8 public minBidIncrementPercentage;
    uint8 public currentTokenId;

    struct Auction {
        uint8 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 bidAmount;
        address payable bidder;
        bool settled;
    }

    address payable private artist = payable(contractOwner);

    mapping(uint256 => Auction) public _auctions;

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

    constructor(INFT _hehe, uint8 _minBidIncrementPercentage) {
        contractOwner = payable(msg.sender);
        hehe = _hehe;
        minBidIncrementPercentage = _minBidIncrementPercentage;

        _pause();
    }

    function unpause(uint256 _auctionId) external onlyOwner {
        require(
            msg.sender == contractOwner,
            "only owner can unpause the contract."
        );
        _unpause();

        if (
            _auctions[_auctionId].startTime == 0 ||
            _auctions[_auctionId].settled
        ) {
            startNewAuction(3 minutes);
        }
    }

    function pause() external onlyOwner {
        require(
            msg.sender == contractOwner,
            "only owner can unpause the contract."
        );
        _pause();
    }

    function startNewAuction(uint256 _duration) internal {
        // mint a new token and store it in the contract
        try hehe.createHehe(address(this)) returns (uint8 _newTokenId) {
            uint256 _startTime = block.timestamp;
            uint256 _endTime = block.timestamp + _duration;

            currentTokenId = _newTokenId;

            _auctions[_newTokenId] = Auction({
                tokenId: _newTokenId,
                startTime: _startTime,
                endTime: _endTime,
                bidAmount: 0,
                bidder: payable(0),
                settled: false
            });

            emit AuctionCreated(_newTokenId, _startTime, _endTime);
        } catch Error(string memory) {
            _pause();
        }
    }

    function bid(uint8 _tokenId) external payable nonReentrant {
        require(
            _auctions[_tokenId].endTime > _auctions[_tokenId].startTime,
            "Auction is not active any longer."
        );
        require(
            msg.value > _auctions[_tokenId].bidAmount,
            "Bid amount not high enough."
        );
        require(
            msg.value >=
                _auctions[_tokenId].bidAmount +
                    ((_auctions[_tokenId].bidAmount *
                        minBidIncrementPercentage) / 100),
            "Must send more than last bid by minBidIncrementPercentage amount"
        );

        // send back tokens to previous bidder
        if (
            _auctions[_tokenId].bidAmount > 0 &&
            address(this).balance >= _auctions[_tokenId].bidAmount
        ) {
            _auctions[_tokenId].bidder.transfer(_auctions[_tokenId].bidAmount);
        }

        _auctions[_tokenId].bidAmount = msg.value;
        _auctions[_tokenId].bidder = payable(msg.sender);

        emit AuctionBid(_tokenId, msg.sender, msg.value);
    }

    function settleAuction(uint8 _tokenId) internal {
        require(_auctions[_tokenId].startTime != 0, "Auction hasn't begun");
        require(
            _auctions[_tokenId].settled != true,
            "Auction already completed."
        );
        require(
            _auctions[_tokenId].endTime <= block.timestamp,
            "Auction hasn't completed."
        );
        require(
            _auctions[_tokenId].bidder == msg.sender,
            "Wrong bidder asking for the Hehe"
        );

        hehe.approve(msg.sender, _tokenId);

        if (_auctions[_tokenId].bidder != address(0)) {
            hehe.transferFrom(
                address(this),
                _auctions[_tokenId].bidder,
                _tokenId
            );
        }

        if (
            _auctions[_tokenId].bidAmount > 0 &&
            address(this).balance >= _auctions[_tokenId].bidAmount
        ) {
            contractOwner.transfer(_auctions[_tokenId].bidAmount);
        }

        _auctions[_tokenId].settled = true;

        emit AuctionSettled(
            _tokenId,
            _auctions[_tokenId].bidder,
            _auctions[_tokenId].bidAmount
        );
    }

    function settleCurrentAndCreateNewAuction() external nonReentrant {
        settleAuction(currentTokenId);
        startNewAuction(3 minutes);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
